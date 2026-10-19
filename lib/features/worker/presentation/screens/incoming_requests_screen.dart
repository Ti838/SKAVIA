import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
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
  int _selectedSegment = 0; // 0: Direct Requests, 1: Open Jobs Feed
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _fetchIncomingRequests();
  }

  Future<void> _fetchIncomingRequests() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() {
            _requests = [];
            _isLoading = false;
          });
        }
        return;
      }

      final workerId = user.uid;

      try {
        final client = Supabase.instance.client;
        final res = await client
            .from('service_requests')
            .select(
              'service_request_id, client_id, status, scheduled_at, agreed_price, service_notes, created_at',
            )
            .eq('status', 'Requested')
            .eq('worker_profile_id', workerId)
            .order('created_at', ascending: false)
            .limit(10);
        if (res.isNotEmpty) {
          _requests = List<Map<String, dynamic>>.from(res);
        } else {
          _requests = [];
        }
      } catch (e) {
        debugPrint('Supabase live fetch error: $e');
        _requests = [];
      }
    } catch (e) {
      debugPrint('Error fetching requests: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _acceptRequest(Map<String, dynamic> request) async {
    final reqId = request['service_request_id']?.toString();
    // Update local list
    setState(() {
      _requests.removeWhere(
        (r) => r['service_request_id'] == request['service_request_id'],
      );
    });

    if (reqId != null && !reqId.startsWith('sr_sample')) {
      try {
        await Supabase.instance.client
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
          'Accepted job: ${request['job_title']}! Opening active job navigation.',
        ),
        backgroundColor: AppColors.success,
      ),
    );

    // Direct worker to active job execution
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActiveJobScreen(
          requestId: request['service_request_id']?.toString() ?? 'req_001',
          clientName: request['client_name']?.toString() ?? 'Client',
          jobTitle: request['job_title']?.toString() ?? 'Service Job',
          location: request['location']?.toString() ?? 'Dhaka',
          agreedPrice: (request['agreed_price'] as num?)?.toDouble() ?? 1000.0,
          expectedOtp: request['job_otp']?.toString() ?? '7241',
          scheduledTime: request['scheduled_at']?.toString() ?? 'Today',
          serviceNotes: request['service_notes']?.toString() ?? '',
        ),
      ),
    );
  }

  void _declineRequest(Map<String, dynamic> request) async {
    final reqId = request['service_request_id']?.toString();
    setState(() {
      _requests.removeWhere(
        (r) => r['service_request_id'] == request['service_request_id'],
      );
    });

    if (reqId != null && !reqId.startsWith('sr_sample')) {
      try {
        await Supabase.instance.client
            .from('service_requests')
            .update({
              'status': 'Cancelled',
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
    return Scaffold(
      backgroundColor: AppColors.primary,
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
          style: AppTypography.headingMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // Worker Dispatch Mode Status Banner
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
              vertical: AppDimensions.paddingSmall,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
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
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Segmented Control: [ Direct Requests (N) | Open Job Feed ]
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
              vertical: 4,
            ),
            child: Container(
              height: 38,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedSegment = 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedSegment == 0
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Direct Requests (${_requests.length})',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _selectedSegment == 0
                                ? AppColors.primary
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
                        decoration: BoxDecoration(
                          color: _selectedSegment == 1
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Open Jobs Feed (লাইভ)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _selectedSegment == 1
                                ? AppColors.primary
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

          // Main 32dp Curved White Content Sheet
          Expanded(
            child: _selectedSegment == 1
                ? const ClipRRect(
                    borderRadius: AppDimensions.roundedSheetTop,
                    child: LiveJobFeedScreen(isTab: true),
                  )
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.sheetBackground,
                      borderRadius: AppDimensions.roundedSheetTop,
                    ),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : _requests.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.inbox_rounded,
                                  size: 64,
                                  color: AppColors.textDisabled,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No pending requests right now',
                                  style: AppTypography.headingSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Keep your status Active to receive instant dispatches.',
                                  style: AppTypography.bodySmall,
                                ),
                                const SizedBox(height: 20),
                                AppButton(
                                  text: 'Refresh Queue',
                                  onPressed: _fetchIncomingRequests,
                                  width: 180,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
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
        ],
      ),
    );
  }
}
