import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';

/// Settings modal bottom sheet
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.language_rounded,
                color: AppColors.primaryRoyal,
              ),
              title: Text(
                AppLanguageService.isBengali
                    ? 'Switch to English'
                    : 'বাংলা ভাষায় পরিবর্তন করুন',
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
              title: Text(AppLanguageService.tr('delete_account')),
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
