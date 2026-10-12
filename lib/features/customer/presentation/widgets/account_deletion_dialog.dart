import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

/// Compliance account deletion modal dialog
class AccountDeletionDialog extends StatefulWidget {
  final AuthController authController;

  const AccountDeletionDialog({super.key, required this.authController});

  static void show(
    BuildContext context, {
    required AuthController authController,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AccountDeletionDialog(authController: authController),
    );
  }

  @override
  State<AccountDeletionDialog> createState() => _AccountDeletionDialogState();
}

class _AccountDeletionDialogState extends State<AccountDeletionDialog> {
  final TextEditingController _confirmController = TextEditingController();
  bool _isDeleting = false;

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _executeAccountDeletion() async {
    final user = widget.authController.user;
    if (user == null) return;
    setState(() => _isDeleting = true);
    try {
      final client = Supabase.instance.client;
      await client
          .from('users')
          .update({'is_active': false, 'full_name': 'Deactivated User'})
          .eq('user_id', user.uid);
      await widget.authController.logout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primaryRoyal,
            content: Text(
              AppLanguageService.isBengali
                  ? 'আপনার অ্যাকাউন্ট সফলভাবে নিষ্ক্রিয় করা হয়েছে।'
                  : 'Your account has been deactivated.',
            ),
          ),
        );
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.onboarding, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete account: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.errorRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.errorRed,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLanguageService.tr('delete_account'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLanguageService.isBengali
                  ? 'অ্যাকাউন্ট মুছে ফেললে আপনার সব ভেরিফায়েড প্রোফাইল তথ্য, এনআইডি হিস্ট্রি এবং অর্জিত রেটিং চিরতরে নিষ্ক্রিয় হয়ে যাবে।'
                  : 'Deleting your account will permanently deactivate your profile, verified NID KYC records, and reputation score.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMedium,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardPeachTint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accentPeach.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: AppColors.accentCoral,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLanguageService.isBengali
                          ? 'আপনার এসক্রো ব্যালেন্স বা কোনো রানিং অর্ডার থাকলে তা আগে সেটেল হতে হবে।'
                          : 'Any escrow deposits or active jobs must be settled before permanent deletion.',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLanguageService.isBengali
                  ? 'নিশ্চিত করতে নিচে "DELETE" টাইপ করুন:'
                  : 'Type "DELETE" below to confirm deletion:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmController,
              decoration: InputDecoration(
                hintText: 'DELETE',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context),
          child: Text(
            AppLanguageService.tr('cancel'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.errorRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed:
              (_confirmController.text.trim().toUpperCase() == 'DELETE' &&
                  !_isDeleting)
              ? _executeAccountDeletion
              : null,
          child: _isDeleting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  AppLanguageService.tr('confirm'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
        ),
      ],
    );
  }
}
