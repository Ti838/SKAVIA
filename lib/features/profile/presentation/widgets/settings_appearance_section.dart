import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/services/app_theme_service.dart';
import '../../../../shared/widgets/app_card.dart';

/// Appearance (Theme mode) and App Language settings section.
class SettingsAppearanceSection extends StatelessWidget {
  const SettingsAppearanceSection({super.key});

  Widget _buildOptionPill(
    BuildContext context, {
    IconData? icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? tokens.brandAccent.withValues(alpha: 0.14)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? tokens.brandAccent : tokens.subtleBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected
                    ? tokens.brandAccent
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? tokens.brandAccent
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    final isBn = context.isBengali;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isBn ? 'অ্যাপের চেহারা ও ভাষা' : 'Appearance & Language',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBn ? 'থিম মোড' : 'Theme Mode',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: AppThemeService.themeModeNotifier,
                builder: (context, mode, _) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      (
                        ThemeMode.system,
                        isBn ? 'অটো (সিস্টেম)' : 'Auto',
                        Icons.brightness_auto_rounded,
                      ),
                      (
                        ThemeMode.light,
                        isBn ? 'লাইট' : 'Light',
                        Icons.light_mode_rounded,
                      ),
                      (
                        ThemeMode.dark,
                        isBn ? 'ডার্ক' : 'Dark',
                        Icons.dark_mode_rounded,
                      ),
                    ].map((item) {
                      final selected = mode == item.$1;
                      return _buildOptionPill(
                        context,
                        icon: item.$3,
                        label: item.$2,
                        selected: selected,
                        onTap: () =>
                            AppThemeService.setThemeMode(item.$1),
                      );
                    }).toList(),
                  );
                },
              ),
              Divider(color: tokens.subtleBorder, height: 22),
              Text(
                isBn ? 'অ্যাপের ভাষা' : 'App Language',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildOptionPill(
                    context,
                    label: 'English',
                    selected: !isBn,
                    onTap: () => AppLanguageService.setLanguage('en'),
                  ),
                  _buildOptionPill(
                    context,
                    label: 'বাংলা (Bengali)',
                    selected: isBn,
                    onTap: () => AppLanguageService.setLanguage('bn'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
