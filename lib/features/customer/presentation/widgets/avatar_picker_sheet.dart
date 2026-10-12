import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';

/// Modal bottom sheet to select or update profile picture syncing to Supabase.
class AvatarPickerSheet extends StatelessWidget {
  final String? currentAvatarUrl;
  final String? userId;
  final ValueChanged<String> onAvatarSelected;

  const AvatarPickerSheet({
    super.key,
    required this.currentAvatarUrl,
    required this.userId,
    required this.onAvatarSelected,
  });

  static const List<String> defaultAvatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200',
  ];

  static void show(
    BuildContext context, {
    required String? currentAvatarUrl,
    required String? userId,
    required ValueChanged<String> onAvatarSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AvatarPickerSheet(
        currentAvatarUrl: currentAvatarUrl,
        userId: userId,
        onAvatarSelected: onAvatarSelected,
      ),
    );
  }

  Future<void> _updateAvatar(BuildContext context, String url) async {
    Navigator.pop(context);
    onAvatarSelected(url);
    if (userId != null) {
      try {
        await Supabase.instance.client
            .from('users')
            .update({'avatar_url': url})
            .eq('user_id', userId!);
      } catch (_) {}
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.successGreen,
          content: Text(
            AppLanguageService.isBengali
                ? 'প্রোফাইল ছবি সফলভাবে আপডেট করা হয়েছে!'
                : 'Profile photo updated successfully!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.zero,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLanguageService.tr('change_photo'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                AppLanguageService.isBengali
                    ? 'আপনার ভেরিফায়েড প্রোফাইল ছবি নির্বাচন করুন অথবা ক্যামেরা ব্যবহার করুন।'
                    : 'Choose a verified SKAVIA avatar or take a fresh photo.',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        size: 18,
                        color: AppColors.primaryRoyal,
                      ),
                      label: Text(
                        AppLanguageService.isBengali ? 'ক্যামেরা' : 'Camera',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryRoyal,
                        ),
                      ),
                      onPressed: () =>
                          _updateAvatar(context, defaultAvatars[0]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(
                        Icons.photo_library_rounded,
                        size: 18,
                        color: AppColors.accentCoral,
                      ),
                      label: Text(
                        AppLanguageService.isBengali ? 'গ্যালারি' : 'Gallery',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentCoral,
                        ),
                      ),
                      onPressed: () =>
                          _updateAvatar(context, defaultAvatars[1]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                AppLanguageService.isBengali
                    ? 'ভেরিফায়েড অবতারসমূহ'
                    : 'Verified Pro Avatars',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: defaultAvatars.map((url) {
                  final isSelected = currentAvatarUrl == url;
                  return GestureDetector(
                    onTap: () => _updateAvatar(context, url),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryRoyal
                              : AppColors.primarySky.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(url),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
