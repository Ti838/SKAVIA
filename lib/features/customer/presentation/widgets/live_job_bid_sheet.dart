import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';
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

  @override
  void initState() {
    super.initState();
    _bidPriceController = TextEditingController(
      text: widget.job.budgetMin.toStringAsFixed(0),
    );
    _arrivalController = TextEditingController(text: '30 mins');
    _proposalNoteController = TextEditingController(
      text: 'Verified specialist with proper inspection equipment ready to dispatch immediately.',
    );
  }

  @override
  void dispose() {
    _bidPriceController.dispose();
    _arrivalController.dispose();
    _proposalNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final job = widget.job;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        18,
        22,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
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
                    color: Colors.grey.shade300,
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
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                job.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryRoyal,
                ),
              ),
              Text(
                'Client Budget: ৳ ${job.budgetMin.toStringAsFixed(0)} - ৳ ${job.budgetMax.toStringAsFixed(0)} • ${job.location}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 16),

              // Bid Price Input
              Text(
                isBn ? 'আপনার প্রস্তাবিত চার্জ (৳)' : 'Your Bid Amount (৳)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _bidPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.payments_rounded,
                    color: AppColors.primarySky,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.sheetSurfaceSubtle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
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
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _arrivalController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.timer_rounded,
                    color: AppColors.accentCoral,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.sheetSurfaceSubtle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
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
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _proposalNoteController,
                maxLines: 2,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.sheetSurfaceSubtle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
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
                    backgroundColor: AppColors.primaryRoyal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.successGreen,
                        content: Text(
                          isBn
                              ? 'বিড সফলভাবে পাঠানো হয়েছে! ক্লায়েন্ট গ্রহণ করলে মেসেজ পাবেন।'
                              : 'Proposal sent to ${job.clientName}! You will be alerted upon client acceptance.',
                        ),
                      ),
                    );
                  },
                  child: Text(
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
