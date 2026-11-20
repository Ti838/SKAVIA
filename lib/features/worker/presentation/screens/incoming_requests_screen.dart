import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/job_otp_util.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../shared/empty_states/empty_data_view.dart';
import '../../../../shared/error_states/error_view.dart';
import '../../../customer/presentation/screens/live_job_feed_screen.dart';
import '../widgets/incoming_request_card.dart';
import 'active_job_screen.dart';

/// Screen for Workers to review, accept, or reject incoming live service requests.
/// Aligned with SKAVIA SRS Section 3.1.H (FR-H02) and table `service_requests`.
class IncomingRequestsScreen extends StatefulWidget {
  final bool isTab;

  const IncomingRequestsScreen({super.key, this.isTab = false});

  @override
  State<IncomingRequestsScreen> createState() => _IncomingRequestsScreenState();
}

class _IncomingRequestsScreenState extends State<IncomingRequestsScreen> {
  bool _isLoading = false;
  bool _hasError = false;
  int _selectedSegment = 0; // 0: Direct Requests, 1: Open Jobs Feed
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _fetchIncomingRequests();
  }

  Future<void> _fetchIncomingRequests() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final client = tryGetSupabaseClient();
      if (user == null || client == null) {
        if (mounted) {
          setState(() {
            _requests = [];
            _isLoading = false;
          });
        }
        return;
      }

      final wpRow = await client
          .from('worker_profiles')
          .select('worker_profile_id')
          .eq('user_id', user.uid)
          .maybeSingle();
      final workerProfileId = wpRow?['worker_profile_id']?.toString();
      if (workerProfileId == null || workerProfileId.isEmpty) {
        _requests = [];
        return;
      }

      final res = await client
          .from('service_requests')
          .select(
            'service_request_id, client_id, status, scheduled_at, agreed_price, '
            'service_notes, created_at, '
            'requirements(title, location), '
            'users(full_name)',
          )
          .eq('status', 'Requested')
          .eq('worker_profile_id', workerProfileId)
          .order('created_at', ascending: false)
          .limit(20);

      _requests = res.map<Map<String, dynamic>>((row) {
        final map = Map<String, dynamic>.from(row);
        final req = map['requirements'] as Map<String, dynamic>?;
        final clientUser = map['users'] as Map<String, dynamic>?;
        map['job_title'] = req?['title']?.toString() ?? 'Service Request';
        map['location'] = req?['location']?.toString() ?? 'Dhaka';
        map['client_name'] = clientUser?['full_name']?.toString() ?? 'Client';
        return map;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching requests: $e');
      _requests = [];
      _hasError = true;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptRequest(Map<String, dynamic> request) async {
    final reqId = request['service_request_id']?.toString();
    setState(() {
      _requests.removeWhere(
        (r) => r['service_request_id'] == request['service_request_id'],
      );
    });

    final client = tryGetSupabaseClient();
    if (client != null && reqId != null && reqId.isNotEmpty) {
      try {
        await client
            .from('service_requests')
            .update({
              'status': 'Accepted',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('service_request_id', reqId);
      } catch (e) {
        debugPrint('[IncomingRequests] Supabase accept status notice: $e');
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Accepted job: ${request['job_title'] ?? 'Service Request'}',
        ),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActiveJobScreen(
          requestId: reqId ?? '',
          clientName: request['client_name']?.toString() ?? 'Client',
          jobTitle: request['job_title']?.toString() ?? 'Service Job',
          location: request['location']?.toString() ?? 'Dhaka',
          agreedPrice: (request['agreed_price'] as num?)?.toDouble() ?? 0.0,
          expectedOtp:
              request['job_otp']?.toString() ??
              JobOtpUtil.extractOtp(
                request['service_notes']?.toString(),
                fallbackRequestId: reqId,
              ),
          scheduledTime: request['scheduled_at']?.toString() ?? '',
          serviceNotes: request['service_notes']?.toString() ?? '',
        ),
      ),
    );
  }

  Future<void> _declineRequest(Map<String, dynamic> request) async {
    final reqId = request['service_request_id']?.toString();
    setState(() {
      _requests.removeWhere(
        (r) => r['service_request_id'] == request['service_request_id'],
      );
    });

    final client = tryGetSupabaseClient();
    if (client != null && reqId != null && reqId.isNotEmpty) {
      try {
        await client
            .from('service_requests')
            .update({
              'status': 'Canceled',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('service_request_id', reqId);
      } catch (e) {
        debugPrint('[IncomingRequests] Supabase decline status notice: $e');
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Request declined. Dispatched to next available specialist in pool.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;

    return Scaffold(
      backgroundColor: tokens.canvasBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: widget.isTab
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: Text(
          'Incoming Job Requests',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.headingMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLarge,
                    vertical: AppDimensions.paddingSmall,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLarge,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.radar_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingMedium),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Radar Dispatch Active',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'You are visible to customers in your service area',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLarge,
                    vertical: 4,
                  ),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 40),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedSegment = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedSegment == 0
                                    ? tokens.cardBg
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Direct (${_requests.length})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: _selectedSegment == 0
                                      ? tokens.brandAccent
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedSegment = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedSegment == 1
                                    ? tokens.cardBg
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Open Jobs Feed',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: _selectedSegment == 1
                                      ? tokens.brandAccent
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
        body: _selectedSegment == 1
            ? const ClipRRect(
                borderRadius: AppDimensions.roundedSheetTop,
                child: LiveJobFeedScreen(isTab: true),
              )
            : Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: tokens.sheetBg,
                  borderRadius: AppDimensions.roundedSheetTop,
                ),
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: tokens.brandAccent,
                        ),
                      )
                    : _hasError
                    ? ErrorView(
                        title: 'Could Not Load Requests',
                        message:
                            'We had trouble fetching incoming requests. Please try again.',
                        onRetry: _fetchIncomingRequests,
                      )
                    : _requests.isEmpty
                    ? EmptyDataView(
                        icon: Icons.inbox_rounded,
                        title: 'No pending requests right now',
                        message:
                            'Keep your availability active to receive direct dispatches from clients.',
                        actionText: 'Refresh Queue',
                        onAction: _fetchIncomingRequests,
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchIncomingRequests,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(
                            AppDimensions.paddingLarge,
                          ),
                          itemCount: _requests.length,
                          itemBuilder: (context, index) {
                            final req = _requests[index];
                            return IncomingRequestCard(
                              request: req,
                              onAccept: () => _acceptRequest(req),
                              onDecline: () => _declineRequest(req),
                            );
                          },
                        ),
                      ),
              ),
      ),
    );
  }
}
