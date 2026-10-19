import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/services/app_theme_service.dart';

/// Modal bottom sheet allowing users to switch between System, Light, and Dark themes.
class ThemePickerSheet extends StatelessWidget {
  const ThemePickerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ThemePickerSheet(),
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
                Navigator.pop(context);
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
                Navigator.pop(context);
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
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
