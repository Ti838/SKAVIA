import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/services/app_theme_service.dart';

/// Settings modal bottom sheet with Language, Theme Mode, and Account deletion
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

  void _showThemePicker(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn ? 'থিম নির্বাচন করুন' : 'Select Theme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Icons.brightness_auto_rounded,
                    color: AppColors.primarySky,
                  ),
                  title: Text(
                    isBn ? 'সিস্টেম অটো (স্বয়ংক্রিয়)' : 'System Default (Auto)',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  trailing: AppThemeService.isSystem
                      ? const Icon(Icons.check_rounded, color: AppColors.primarySky)
                      : null,
                  onTap: () {
                    AppThemeService.setThemeMode(ThemeMode.system);
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.light_mode_rounded,
                    color: Color(0xFFF59E0B),
                  ),
                  title: Text(
                    isBn ? 'লাইট মোড (উজ্জ্বল)' : 'Light Mode',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  trailing: AppThemeService.isLight
                      ? const Icon(Icons.check_rounded, color: AppColors.primarySky)
                      : null,
                  onTap: () {
                    AppThemeService.setThemeMode(ThemeMode.light);
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.dark_mode_rounded,
                    color: Color(0xFF6366F1),
                  ),
                  title: Text(
                    isBn ? 'ডার্ক মোড (অন্ধকার)' : 'Dark Mode',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  trailing: AppThemeService.isDark
                      ? const Icon(Icons.check_rounded, color: AppColors.primarySky)
                      : null,
                  onTap: () {
                    AppThemeService.setThemeMode(ThemeMode.dark);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
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
                    onTap: () => _showThemePicker(context),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.language_rounded,
                  color: AppColors.primaryRoyal,
                ),
                title: Text(
                  isBn
                      ? 'Switch to English'
                      : 'বাংলা ভাষায় পরিবর্তন করুন',
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
