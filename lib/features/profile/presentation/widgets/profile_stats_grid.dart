import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/profile_stats_model.dart';

/// Real Profile Activity Stats Card displaying services, projects, and verified rating.
class ProfileStatsGrid extends StatelessWidget {
  final ProfileStatsModel stats;

  const ProfileStatsGrid({super.key, required this.stats});

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final l10n = context.l10n;
    final isBn = context.isBengali;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 300 || textScale > 1.45;
        final ratingDisplay = stats.hasVerifiedRating
            ? stats.ratingAverage.toStringAsFixed(1)
            : '—';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: tokens.cardBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: tokens.border),
          ),
          child: compact
              ? Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _buildStatColumn(
                      context,
                      Formatters.toBengaliDigits(stats.servicesCount),
                      l10n.profileServicesStat,
                    ),
                    _buildStatColumn(
                      context,
                      Formatters.toBengaliDigits(stats.projectsCount),
                      l10n.profileProjectsStat,
                    ),
                    _buildStatColumn(
                      context,
                      isBn && stats.hasVerifiedRating
                          ? Formatters.toBengaliDigits(ratingDisplay)
                          : ratingDisplay,
                      l10n.profileRatingStat,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildStatColumn(
                        context,
                        Formatters.toBengaliDigits(stats.servicesCount),
                        l10n.profileServicesStat,
                      ),
                    ),
                    Container(height: 32, width: 1, color: tokens.border),
                    Expanded(
                      child: _buildStatColumn(
                        context,
                        Formatters.toBengaliDigits(stats.projectsCount),
                        l10n.profileProjectsStat,
                      ),
                    ),
                    Container(height: 32, width: 1, color: tokens.border),
                    Expanded(
                      child: _buildStatColumn(
                        context,
                        isBn && stats.hasVerifiedRating
                            ? Formatters.toBengaliDigits(ratingDisplay)
                            : ratingDisplay,
                        l10n.profileRatingStat,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
