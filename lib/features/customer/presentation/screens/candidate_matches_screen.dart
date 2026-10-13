import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../matching/presentation/controllers/matching_controller.dart';
import '../widgets/candidate_match_card.dart';

/// Screen displaying the algorithmic ranked match results for a Customer or Business Client requirement.
/// Aligned with SRS Section 3.1.G (FR-G01 - FR-G04).
class CandidateMatchesScreen extends StatefulWidget {
  final String requirementId;
  final String requirementTitle;
  final String requirementZone;
  final double budget;
  final bool isComplexProject;

  const CandidateMatchesScreen({
    super.key,
    required this.requirementId,
    required this.requirementTitle,
    required this.requirementZone,
    required this.budget,
    this.isComplexProject = false,
  });

  @override
  State<CandidateMatchesScreen> createState() => _CandidateMatchesScreenState();
}

class _CandidateMatchesScreenState extends State<CandidateMatchesScreen> {
  late final MatchingController _matchingController;

  @override
  void initState() {
    super.initState();
    _matchingController = MatchingController();
    _loadMatches();
  }

  void _loadMatches() {
    _matchingController.findMatches(
      requirementId: widget.requirementId,
      requirementZone: widget.requirementZone,
      clientBudget: widget.budget,
    );
  }

  @override
  void dispose() {
    _matchingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isComplexProject
              ? 'Proposed Project Team'
              : 'Matched Specialists',
          style: AppTypography.headingMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header requirement summary card
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
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.requirementTitle,
                          style: AppTypography.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.requirementZone} • Budget: ৳ ${widget.budget.toStringAsFixed(0)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),

          // Main 32dp Curved White Content Sheet
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.sheetBackground,
                borderRadius: AppDimensions.roundedSheetTop,
              ),
              child: ListenableBuilder(
                listenable: _matchingController,
                builder: (context, _) {
                  if (_matchingController.isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 16),
                          Text(
                            'Evaluating algorithmic match score...',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final matches = _matchingController.matches;

                  if (matches.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person_search_rounded,
                            size: 64,
                            color: AppColors.textDisabled,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No matched specialists found in this zone',
                            style: AppTypography.headingSmall,
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            text: 'Re-evaluate Matches',
                            onPressed: _loadMatches,
                            width: 200,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    itemCount: matches.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingMedium,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${matches.length} Top Algorithmic Matches',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'SRS Rule-Based',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final candidate = matches[index - 1];
                      return CandidateMatchCard(
                        candidate: candidate,
                        requirementTitle: widget.requirementTitle,
                        requirementZone: widget.requirementZone,
                      );
                    },
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
