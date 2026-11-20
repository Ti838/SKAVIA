import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/empty_states/empty_data_view.dart';
import '../../../../shared/error_states/error_view.dart';
import '../../../../shared/widgets/app_app_bar.dart';
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
  final String? categoryId;

  const CandidateMatchesScreen({
    super.key,
    required this.requirementId,
    required this.requirementTitle,
    required this.requirementZone,
    required this.budget,
    this.isComplexProject = false,
    this.categoryId,
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
      categoryId: widget.categoryId,
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
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: tokens.sheetBg,
      appBar: AppAppBar(
        title: widget.isComplexProject
            ? l10n.matchingTeamTitle
            : l10n.matchingTitle,
      ),
      body: Column(
        children: [
          // Header requirement summary card
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingMedium,
              AppDimensions.paddingSmall,
              AppDimensions.paddingMedium,
              AppDimensions.paddingSmall,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: tokens.cardBg,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: tokens.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: tokens.softVioletBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: tokens.violetAccent,
                      size: 20,
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
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.budget > 0
                              ? '${widget.requirementZone} · Budget: ৳ ${widget.budget.toStringAsFixed(0)}'
                              : widget.requirementZone,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: tokens.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
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
                          CircularProgressIndicator(color: tokens.brandAccent),
                          const SizedBox(height: 16),
                          Text(
                            l10n.matchingEvaluating,
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

                if (_matchingController.errorMessage != null) {
                  return ErrorView(
                    title: l10n.matchingErrorTitle,
                    message: l10n.commonConnectionError,
                    onRetry: _loadMatches,
                  );
                }

                final matches = _matchingController.matches;

                if (matches.isEmpty) {
                  return EmptyDataView(
                    icon: Icons.person_search_rounded,
                    title: l10n.matchingEmptyTitle,
                    message: l10n.matchingEmptyMessage,
                    actionText: l10n.matchingReevaluate,
                    onAction: _loadMatches,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
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
        ],
      ),
    );
  }
}
