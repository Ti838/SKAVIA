import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/datasources/review_remote_datasource.dart';
import '../widgets/review_compliments_section.dart';
import '../widgets/review_rating_selector.dart';
import '../widgets/review_worker_card.dart';

class SubmitReviewScreen extends StatefulWidget {
  final String workerProfileId;
  final String workerName;
  final String? workerAvatar;
  final String? serviceRequestId;
  final String? projectId;

  const SubmitReviewScreen({
    super.key,
    required this.workerProfileId,
    required this.workerName,
    this.workerAvatar,
    this.serviceRequestId,
    this.projectId,
  });

  @override
  State<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends State<SubmitReviewScreen> {
  final ReviewRemoteDataSource _reviewDataSource = ReviewRemoteDataSource();
  final AuthController _authController = AuthController();
  final TextEditingController _commentController = TextEditingController();

  int _rating = 5;
  bool _isSubmitting = false;
  final Set<String> _selectedCompliments = {};

  final List<String> _complimentTags = [
    'Punctual & On-Time',
    'High Quality Work',
    'Courteous & Professional',
    'Fair & Transparent Pricing',
    'Clean Work Site',
    'Highly Recommended',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    _authController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final user = _authController.user;
    final clientId = user?.uid ?? 'guest_client';

    setState(() => _isSubmitting = true);

    String finalComment = _commentController.text.trim();
    if (_selectedCompliments.isNotEmpty) {
      final tagsText = _selectedCompliments.join(', ');
      finalComment = finalComment.isNotEmpty
          ? '$finalComment\n\nHighlights: $tagsText'
          : 'Highlights: $tagsText';
    }

    try {
      await _reviewDataSource.submitReview(
        workerProfileId: widget.workerProfileId,
        clientId: clientId,
        rating: _rating,
        comment: finalComment.isNotEmpty
            ? finalComment
            : 'Verified 5-Star Service Completed',
        serviceRequestId: widget.serviceRequestId,
        projectId: widget.projectId,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.successGreen,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Review Submitted',
                  style: TextStyle(
                    fontFamily: AppTypography.headingFont,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Your review for ${widget.workerName} has been recorded on the live blockchain-grade reputation ledger.',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              child: const Text(
                'Done',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit review: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBlue,
      appBar: AppBar(
        backgroundColor: AppColors.canvasBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rate & Review Specialist',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: AppDimensions.roundedSheet,
          ),
          child: ClipRRect(
            borderRadius: AppDimensions.roundedSheet,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Worker profile summary card
                  ReviewWorkerCard(
                    workerName: widget.workerName,
                    workerAvatar: widget.workerAvatar,
                  ),

                  const SizedBox(height: 28),

                  // Rating Section
                  ReviewRatingSelector(
                    rating: _rating,
                    onRatingChanged: (val) => setState(() => _rating = val),
                  ),

                  const SizedBox(height: 28),

                  // Compliments / Tags
                  ReviewComplimentsSection(
                    availableTags: _complimentTags,
                    selectedTags: _selectedCompliments,
                    onTagToggled: (tag) {
                      setState(() {
                        if (_selectedCompliments.contains(tag)) {
                          _selectedCompliments.remove(tag);
                        } else {
                          _selectedCompliments.add(tag);
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Comment Text Area
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Write Detailed Review (Optional)',
                      style: TextStyle(
                        fontFamily: AppTypography.headingFont,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.sheetSurfaceSubtle,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: _commentController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Share feedback regarding quality, punctuality, and tools...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  AppButton(
                    text: 'Submit Honest Review ⭐',
                    isLoading: _isSubmitting,
                    onPressed: _submitReview,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
