import 'package:flutter/material.dart';

import '../../app/router/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/services/app_language_service.dart';
import '../../features/authentication/presentation/controllers/auth_controller.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';

/// Shared compliance account deletion modal dialog supporting 30-day grace period.
class AccountDeletionDialog extends StatefulWidget {
  final AuthController authController;
  final ProfileRemoteDataSource? profileDataSource;
  final Future<void> Function(String reason)? onConfirmedDeletion;
  final bool showReasonField;
  final String postLogoutRoute;

  const AccountDeletionDialog({
    super.key,
    required this.authController,
    this.profileDataSource,
    this.onConfirmedDeletion,
    this.showReasonField = false,
    this.postLogoutRoute = AppRoutes.onboarding,
  });

  static Future<void> show(
    BuildContext context, {
    required AuthController authController,
    ProfileRemoteDataSource? profileDataSource,
    Future<void> Function(String reason)? onConfirmedDeletion,
    bool showReasonField = false,
    String postLogoutRoute = AppRoutes.onboarding,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AccountDeletionDialog(
        authController: authController,
        profileDataSource: profileDataSource,
        onConfirmedDeletion: onConfirmedDeletion,
        showReasonField: showReasonField,
        postLogoutRoute: postLogoutRoute,
      ),
    );
  }

  @override
  State<AccountDeletionDialog> createState() => _AccountDeletionDialogState();
}

class _AccountDeletionDialogState extends State<AccountDeletionDialog> {
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  bool _isDeleting = false;

  @override
  void dispose() {
    _confirmController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _executeAccountDeletion() async {
    final user = widget.authController.user;
    if (user == null && widget.onConfirmedDeletion == null) return;
    setState(() => _isDeleting = true);
    final reason = _reasonController.text.trim().isEmpty
        ? 'User requested account deletion'
        : _reasonController.text.trim();

    try {
      if (widget.onConfirmedDeletion != null) {
        await widget.onConfirmedDeletion!(reason);
      } else if (user != null) {
        await (widget.profileDataSource ?? ProfileRemoteDataSource())
            .requestAccountDeletion(user.uid, reason);
      }

      await widget.authController.logout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primaryRoyal,
            content: Text(
              AppLanguageService.isBengali
                  ? 'আপনার অ্যাকাউন্ট ৩০ দিনের গ্রেস পিরিয়ডসহ নিষ্ক্রিয় করা হয়েছে।'
                  : 'Your account has been deactivated with a 30-day grace period.',
            ),
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          widget.postLogoutRoute,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    final isBn = AppLanguageService.isBengali;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.errorRed.withValues(alpha: 0.12),
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
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
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
              isBn
                  ? 'অ্যাকাউন্ট মুছে ফেললে আপনার প্রোফাইল, ভেরিফায়েড এনআইডি রেকর্ড ও রেটিং ৩০ দিনের গ্রেস পিরিয়ডের পর নিষ্ক্রিয় হয়ে যাবে।'
                  : 'Deleting your account enters a 30-day grace period before permanently deactivating your profile, verified NID KYC records, and reputation score.',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tokens.softPeachBg,
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
                      isBn
                          ? 'আপনার এসক্রো ব্যালেন্স বা কোনো রানিং অর্ডার থাকলে তা আগে সেটেল হতে হবে।'
                          : 'Any escrow deposits or active jobs must be settled before permanent deletion.',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.showReasonField) ...[
              const SizedBox(height: 14),
              TextField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: 'Reason for leaving (Optional)',
                  hintText: 'e.g. Relocating, No longer need services',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
            ],
            const SizedBox(height: 16),
            Text(
              isBn
                  ? 'নিশ্চিত করতে নিচে "DELETE" টাইপ করুন:'
                  : 'Type "DELETE" below to confirm deletion:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
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
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      actions: [
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          runSpacing: 6,
          children: [
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
        ),
      ],
    );
  }
}

