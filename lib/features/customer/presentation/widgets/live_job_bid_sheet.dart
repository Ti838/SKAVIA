import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../core/utils/uuid_util.dart';
import '../../../../data/tables/database_tables.dart';
import '../../data/models/requirement_model.dart';

/// Modal bottom sheet for workers to submit direct bids to client requirements
class LiveJobBidSheet extends StatefulWidget {
  final JobRequirementItem job;

  const LiveJobBidSheet({super.key, required this.job});

  static Future<void> show(BuildContext context, JobRequirementItem job) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LiveJobBidSheet(job: job),
    );
  }

  @override
  State<LiveJobBidSheet> createState() => _LiveJobBidSheetState();
}

class _LiveJobBidSheetState extends State<LiveJobBidSheet> {
  late final TextEditingController _bidPriceController;
  late final TextEditingController _arrivalController;
  late final TextEditingController _proposalNoteController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _bidPriceController = TextEditingController(
      text: widget.job.budgetMin.toStringAsFixed(0),
    );
    _arrivalController = TextEditingController(text: '30 mins');
    _proposalNoteController = TextEditingController(
      text:
          'Verified specialist with proper inspection equipment ready to dispatch immediately.',
    );
  }

  @override
  void dispose() {
    _bidPriceController.dispose();
    _arrivalController.dispose();
    _proposalNoteController.dispose();
    super.dispose();
  }

  User? _safeCurrentUser() {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  Future<void> _submitProposal() async {
    if (_isSubmitting) return;
    final user = _safeCurrentUser();
    if (user == null) {
      UiFeedbackHelper.showError(
        context,
        'Authentication required. Please sign in to submit a proposal.',
      );
      return;
    }

    final client = tryGetSupabaseClient();
    if (client == null) {
      UiFeedbackHelper.showError(
        context,
        'Offline mode: submitting a proposal requires an active backend connection.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Look up authentic worker_profile_id for this authenticated worker
      final wp = await client
          .from(DatabaseTables.workerProfiles)
          .select('worker_profile_id')
          .eq('user_id', user.uid)
          .maybeSingle();

      final workerProfileId = wp?['worker_profile_id']?.toString();
      if (workerProfileId == null || !UuidUtil.isValidUuid(workerProfileId)) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          UiFeedbackHelper.showError(
            context,
            'Complete your Worker Profile first before submitting direct service bids.',
          );
        }
        return;
      }

      String? clientId = widget.job.submittedBy;
      if ((clientId == null || clientId.isEmpty) &&
          UuidUtil.isValidUuid(widget.job.id)) {
        final reqRow = await client
            .from(DatabaseTables.requirements)
            .select('submitted_by')
            .eq('requirement_id', widget.job.id)
            .maybeSingle();
        clientId = reqRow?['submitted_by']?.toString();
      }

      if (clientId == null ||
          clientId.isEmpty ||
          clientId == user.uid ||
          !UuidUtil.isValidUuid(widget.job.id)) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          UiFeedbackHelper.showError(
            context,
            clientId == user.uid
                ? 'You cannot submit a service proposal on your own requirement.'
                : 'This sample post cannot accept live bids. Please open a live requirement.',
          );
        }
        return;
      }

      final proposedPrice =
          double.tryParse(_bidPriceController.text.trim()) ??
          widget.job.budgetMin;
      final note = _proposalNoteController.text.trim();

      await client.from(DatabaseTables.serviceRequests).insert({
        'requirement_id': widget.job.id,
        'client_id': clientId,
        'worker_profile_id': workerProfileId,
        'status': 'Requested',
        'agreed_price': proposedPrice,
        'service_notes':
            'Bid Proposal: $note | ETA: ${_arrivalController.text.trim()}',
        'scheduled_at': DateTime.now()
            .add(const Duration(hours: 1))
            .toIso8601String(),
      });

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final isBn = AppLanguageService.isBengali;
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.successGreen,
          content: Text(
            isBn
                ? 'বিড সফলভাবে পাঠানো হয়েছে! ক্লায়েন্ট গ্রহণ করলে মেসেজ পাবেন।'
                : 'Proposal sent to ${widget.job.clientName}! You will be alerted upon client acceptance.',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        UiFeedbackHelper.showError(context, 'Failed to submit proposal: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final job = widget.job;
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

    return Container(
      decoration: BoxDecoration(
        color: tokens.sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        18,
        22,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tokens.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isBn
                          ? 'কাজের বিড প্রস্তাব (Submit Bid)'
                          : 'Submit Direct Proposal',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed:
                        _isSubmitting ? null : () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                job.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: tokens.brandAccent,
                ),
              ),
              Text(
                'Client Budget: ৳ ${job.budgetMin.toStringAsFixed(0)} - ৳ ${job.budgetMax.toStringAsFixed(0)} • ${job.location}',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Bid Price Input
              Text(
                isBn ? 'আপনার প্রস্তাবিত চার্জ (৳)' : 'Your Bid Amount (৳)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _bidPriceController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.payments_rounded,
                    color: AppColors.primarySky,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: tokens.subtleCardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: tokens.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Earliest Arrival Time
              Text(
                isBn ? 'কখন পৌঁছাতে পারবেন?' : 'Estimated Arrival Time',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _arrivalController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.timer_rounded,
                    color: AppColors.accentCoral,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: tokens.subtleCardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: tokens.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Proposal Note
              Text(
                isBn
                    ? 'কাজের অভিজ্ঞতা ও সংক্ষিপ্ত নোট'
                    : 'Brief Proposal Message',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _proposalNoteController,
                maxLines: 2,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: tokens.subtleCardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: tokens.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Submit Bid Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.brandAccent,
                    foregroundColor: tokens.onBrandAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _isSubmitting ? null : _submitProposal,
                  child: _isSubmitting
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: tokens.onBrandAccent,
                          ),
                        )
                      : Text(
                          isBn
                              ? 'বিড নিশ্চিত করুন (Confirm Proposal)'
                              : 'Submit Proposal to Client',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
