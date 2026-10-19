import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/services/app_theme_service.dart';
import 'legal_policies_sheet.dart';
import 'theme_picker_sheet.dart';

/// Settings modal bottom sheet with Language, Theme Mode, Legal & Policies, and Account deletion.
/// Fulfills Section 14 (Product Owner Decision Authority) for transparent marketplace rules,
/// explicit consent, and data protection disclosures.
class DashboardSettingsSheet extends StatelessWidget {
  final VoidCallback onDeleteAccount;

  const DashboardSettingsSheet({super.key, required this.onDeleteAccount});

  static void show(
    BuildContext context, {
    required VoidCallback onDeleteAccount,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) =>
          DashboardSettingsSheet(onDeleteAccount: onDeleteAccount),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                isBn ? 'সেটিংস' : 'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Theme Mode Selector
              ValueListenableBuilder<ThemeMode>(
                valueListenable: AppThemeService.themeModeNotifier,
                builder: (context, mode, _) {
                  final icon = mode == ThemeMode.dark
                      ? Icons.dark_mode_rounded
                      : mode == ThemeMode.light
                      ? Icons.light_mode_rounded
                      : Icons.brightness_auto_rounded;

                  return ListTile(
                    leading: Icon(icon, color: AppColors.primaryRoyal),
                    title: Text(
                      isBn ? 'অ্যাপ থিম' : 'App Theme',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      AppThemeService.getThemeLabel(isBengali: isBn),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => ThemePickerSheet.show(context),
                  );
                },
              ),

              // Language Toggle
              ListTile(
                leading: const Icon(
                  Icons.language_rounded,
                  color: AppColors.primaryRoyal,
                ),
                title: Text(
                  isBn ? 'Switch to English' : 'বাংলা ভাষায় পরিবর্তন করুন',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                  AppLanguageService.toggleLanguage();
                },
              ),

              // Legal & Policies Section (Fulfills Section 14)
              ListTile(
                leading: const Icon(
                  Icons.policy_rounded,
                  color: AppColors.primarySky,
                ),
                title: Text(
                  isBn
                      ? 'আইনি নীতিমালা ও স্বচ্ছ ফি'
                      : 'Legal & Platform Policies',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  isBn
                      ? 'শর্তাবলী, গোপনীয়তা, ১৫% স্বচ্ছ ফি'
                      : 'Terms, Privacy, 15% Fee Schedule',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => LegalPoliciesSheet.show(context),
              ),

              // Account Deletion Action
              ListTile(
                leading: const Icon(
                  Icons.delete_forever_rounded,
                  color: AppColors.errorRed,
                ),
                title: Text(
                  AppLanguageService.tr('delete_account'),
                  style: const TextStyle(
                    color: AppColors.errorRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                  onDeleteAccount();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
