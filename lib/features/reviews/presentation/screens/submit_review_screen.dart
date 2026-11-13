import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_app_bar.dart';
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

  final List<String> _complimentTags = const [
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
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to submit a verified specialist review.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

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
        clientId: user.uid,
        rating: _rating,
        comment: finalComment.isNotEmpty
            ? finalComment
            : 'Verified $_rating-Star Service Completed',
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
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.successGreen,
                size: 28,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Review Submitted',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            'Your review for ${widget.workerName} has been submitted to their verified SKAVIA reputation profile.',
            style: const TextStyle(fontSize: 14, height: 1.4),
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
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: tokens.sheetBg,
      appBar: const AppAppBar(title: 'Rate & Review Specialist'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ReviewWorkerCard(
                workerName: widget.workerName,
                workerAvatar: widget.workerAvatar,
              ),

              const SizedBox(height: 24),

              ReviewRatingSelector(
                rating: _rating,
                onRatingChanged: (val) => setState(() => _rating = val),
              ),

              const SizedBox(height: 24),

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

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Write Detailed Review (Optional)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: tokens.inputBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: tokens.border),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _commentController,
                  maxLines: 4,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Share feedback regarding quality, punctuality, and tools...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: tokens.mutedText,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              AppButton(
                text: 'Submit Review',
                isLoading: _isSubmitting,
                onPressed: _submitReview,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
