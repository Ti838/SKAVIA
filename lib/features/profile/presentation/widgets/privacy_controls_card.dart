import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_card.dart';
import '../controllers/profile_controller.dart';

/// Privacy controls card for Profile directory visibility and phone sharing consent.
class PrivacyControlsCard extends StatelessWidget {
  final ProfileController controller;
  final Map<String, dynamic> privacy;

  const PrivacyControlsCard({
    super.key,
    required this.controller,
    required this.privacy,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    final sharePhone =
        privacy['share_phone_with_assigned_specialist'] as bool? ?? true;
    final dataConsent = privacy['data_sharing_consent'] as bool? ?? true;
    final visibility = privacy['profile_visibility']?.toString() ?? 'public';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy Controls',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Directory Visibility',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children:
                    [
                      ('public', 'Public'),
                      ('verified_only', 'Verified Users'),
                      ('private', 'Private'),
                    ].map((entry) {
                      final active = visibility == entry.$1;
                      return InkWell(
                        onTap: () {
                          final next = Map<String, dynamic>.from(privacy);
                          next['profile_visibility'] = entry.$1;
                          controller.updatePrivacySettings(next);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? tokens.brandAccent.withValues(alpha: 0.16)
                                : colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: active
                                  ? tokens.brandAccent
                                  : tokens.subtleBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (active) ...[
                                Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: tokens.brandAccent,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child: Text(
                                  entry.$2,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: active
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: active
                                        ? tokens.brandAccent
                                        : colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
              Divider(color: tokens.subtleBorder, height: 22),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Share Phone with Assigned Specialist',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Allows your technician to call upon dispatch confirmation',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: sharePhone,
                activeThumbColor: tokens.brandAccent,
                onChanged: (val) {
                  final next = Map<String, dynamic>.from(privacy);
                  next['share_phone_with_assigned_specialist'] = val;
                  controller.updatePrivacySettings(next);
                },
              ),
              Divider(color: tokens.subtleBorder, height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Service Quality & Analytics Consent',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Helps SKAVIA improve branch dispatch matching accuracy',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: dataConsent,
                activeThumbColor: tokens.brandAccent,
                onChanged: (val) {
                  final next = Map<String, dynamic>.from(privacy);
                  next['data_sharing_consent'] = val;
                  controller.updatePrivacySettings(next);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
