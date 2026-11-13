import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
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
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

    return Scaffold(
      backgroundColor: tokens.canvasBg,
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.textDark,
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.requirementZone} • Budget: ৳ ${widget.budget.toStringAsFixed(0)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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

          // Main 32dp Curved Content Sheet
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: tokens.sheetBg,
                borderRadius: AppDimensions.roundedSheetTop,
              ),
              child: ListenableBuilder(
                listenable: _matchingController,
                builder: (context, _) {
                  if (_matchingController.isLoading) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: tokens.brandAccent,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Evaluating algorithmic match score...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final matches = _matchingController.matches;

                  if (matches.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search_rounded,
                              size: 64,
                              color: tokens.mutedText,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No matched specialists found in this zone',
                              textAlign: TextAlign.center,
                              style: AppTypography.headingSmall.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 260),
                              child: AppButton(
                                text: 'Re-evaluate Matches',
                                onPressed: _loadMatches,
                              ),
                            ),
                          ],
                        ),
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
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              Text(
                                '${matches.length} Top Algorithmic Matches',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: tokens.softBlueBg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'SRS Rule-Based',
                                  style: AppTypography.caption.copyWith(
                                    color: tokens.brandAccent,
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
