import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/services/media_picker_service.dart';
import '../../../../core/storage/remote_storage_datasource.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../data/tables/database_tables.dart';
import '../../../../shared/screens/image_crop_resize_screen.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';

enum ProfileMediaSlot { avatar, cover }

/// Modal bottom sheet to pick, interactively crop/resize, and upload a real
/// profile photo (1:1 circle) or Facebook-style cover banner (16:9).
class AvatarPickerSheet extends StatefulWidget {
  final String? currentAvatarUrl;
  final String? userId;
  final ValueChanged<String> onAvatarSelected;
  final ProfileMediaSlot slot;

  const AvatarPickerSheet({
    super.key,
    required this.currentAvatarUrl,
    required this.userId,
    required this.onAvatarSelected,
    this.slot = ProfileMediaSlot.avatar,
  });

  static void show(
    BuildContext context, {
    required String? currentAvatarUrl,
    required String? userId,
    required ValueChanged<String> onAvatarSelected,
    ProfileMediaSlot slot = ProfileMediaSlot.avatar,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AvatarPickerSheet(
        currentAvatarUrl: currentAvatarUrl,
        userId: userId,
        onAvatarSelected: onAvatarSelected,
        slot: slot,
      ),
    );
  }

  @override
  State<AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<AvatarPickerSheet> {
  final TextEditingController _urlController = TextEditingController();
  bool _isUploading = false;
  bool _showUrlField = false;

  bool get _isCover => widget.slot == ProfileMediaSlot.cover;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickCropAndUpload({required bool fromCamera}) async {
    if (_isUploading) return;
    setState(() => _isUploading = true);

    File? croppedFile;
    try {
      final pickedFile = await MediaPickerService.pickImage(
        fromCamera: fromCamera,
      );
      if (pickedFile == null) {
        if (mounted) {
          setState(() => _isUploading = false);
          UiFeedbackHelper.showInfo(
            context,
            AppLanguageService.isBengali
                ? 'কোনো ছবি নির্বাচন করা হয়নি।'
                : 'No photo selected.',
          );
        }
        return;
      }

      if (!mounted) return;
      croppedFile = await ImageCropResizeScreen.open(
        context,
        imageFile: pickedFile,
        isBanner: _isCover,
      );

      if (!mounted) return;
      if (croppedFile == null) {
        setState(() => _isUploading = false);
        return;
      }

      final prefix = _isCover ? 'cover' : 'avatar';
      final result = await RemoteStorageDataSource().uploadFileDetailed(
        file: croppedFile,
        path: '${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        bucket: StorageBuckets.avatars,
        mimeType: 'image/jpeg',
      );

      if (!mounted) return;
      if (result.isSuccess && result.url != null) {
        await _persistAndClose(result.url!);
      } else {
        setState(() => _isUploading = false);
        UiFeedbackHelper.showError(
          context,
          result.errorMessage ?? 'Failed to upload image.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        UiFeedbackHelper.showError(context, 'Upload failed: $e');
      }
    } finally {
      if (croppedFile != null) {
        final cleanup = croppedFile;
        unawaited(cleanup.delete().catchError((_) => cleanup));
      }
    }
  }

  Future<void> _persistAndClose(String url) async {
    final trimmed = url.trim();
    if (!_isUploading && mounted) {
      setState(() => _isUploading = true);
    }

    if (widget.userId != null && widget.userId!.isNotEmpty) {
      final supabase = tryGetSupabaseClient();
      if (supabase != null) {
        try {
          if (_isCover) {
            await supabase
                .from(DatabaseTables.users)
                .update({'cover_url': trimmed.isEmpty ? null : trimmed})
                .eq('user_id', widget.userId!);
          } else {
            await supabase
                .from(DatabaseTables.users)
                .update({'avatar_url': trimmed.isEmpty ? null : trimmed})
                .eq('user_id', widget.userId!);
          }
        } catch (_) {}
      }
    }

    if (!_isCover) {
      try {
        final fbUser = FirebaseAuth.instance.currentUser;
        if (fbUser != null) {
          await fbUser.updatePhotoURL(trimmed.isEmpty ? null : trimmed);
        }
      } catch (_) {}
    }

    if (ProfileController.shared.profile != null) {
      if (_isCover) {
        await ProfileController.shared.updateProfile(coverUrl: trimmed);
      } else {
        await ProfileController.shared.updateProfile(avatarUrl: trimmed);
      }
    }

    widget.onAvatarSelected(trimmed);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.successGreen,
        content: Text(
          _isCover
              ? (trimmed.isEmpty
                    ? (AppLanguageService.isBengali
                          ? 'কভার ব্যানার সরানো হয়েছে।'
                          : 'Cover banner removed.')
                    : (AppLanguageService.isBengali
                          ? 'কভার ব্যানার সফলভাবে আপডেট হয়েছে!'
                          : 'Cover banner updated successfully!'))
              : (trimmed.isEmpty
                    ? (AppLanguageService.isBengali
                          ? 'প্রোফাইল ছবি সরানো হয়েছে।'
                          : 'Profile photo removed.')
                    : (AppLanguageService.isBengali
                          ? 'প্রোফাইল ছবি সফলভাবে আপডেট হয়েছে!'
                          : 'Profile photo updated successfully!')),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    final isBn = AppLanguageService.isBengali;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final hasCurrentPhoto =
        widget.currentAvatarUrl != null &&
        widget.currentAvatarUrl!.trim().isNotEmpty;
    final profileName =
        ProfileController.shared.profile?.fullName ?? 'SKAVIA Member';

    final heading = _isCover
        ? (isBn ? 'কভার ব্যানার পরিবর্তন করুন' : 'Change Cover Banner')
        : AppLanguageService.tr('change_photo');
    final subheading = _isCover
        ? (isBn
              ? 'ক্যামেরা বা গ্যালারি থেকে ব্যানার নিয়ে ১৬:৯ মাপে রিসাইজ করুন।'
              : 'Pick from camera or gallery, then crop & resize to 16:9.')
        : (isBn
              ? 'ক্যামেরা বা গ্যালারি থেকে ছবি নিয়ে জুম ও রিসাইজ করে আপলোড করুন।'
              : 'Pick from camera or gallery, then zoom & resize before saving.');

    return Container(
      decoration: BoxDecoration(
        color: tokens.sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
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
                    color: tokens.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_isCover)
                    Container(
                      width: 56,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.primaryRoyal.withValues(alpha: 0.14),
                        border: Border.all(color: tokens.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: hasCurrentPhoto
                          ? Image.network(
                              widget.currentAvatarUrl!.trim(),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(
                                Icons.panorama_rounded,
                                color: tokens.brandAccent,
                                size: 20,
                              ),
                            )
                          : Icon(
                              Icons.panorama_rounded,
                              color: tokens.brandAccent,
                              size: 20,
                            ),
                    )
                  else
                    UserAvatar(
                      imageUrl: widget.currentAvatarUrl,
                      name: profileName,
                      radius: 22,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          heading,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subheading,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isUploading
                        ? null
                        : () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (_isUploading) ...[
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(4),
                  color: tokens.brandAccent,
                ),
              ],
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stackButtons =
                      constraints.maxWidth < 330 || textScale > 1.35;
                  final cameraBtn = OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: Icon(
                      Icons.camera_alt_rounded,
                      size: 18,
                      color: tokens.brandAccent,
                    ),
                    label: Text(
                      isBn ? 'ক্যামেরা' : 'Camera',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: tokens.brandAccent,
                      ),
                    ),
                    onPressed: _isUploading
                        ? null
                        : () => _pickCropAndUpload(fromCamera: true),
                  );
                  final galleryBtn = OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
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
                      isBn ? 'গ্যালারি' : 'Gallery',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentCoral,
                      ),
                    ),
                    onPressed: _isUploading
                        ? null
                        : () => _pickCropAndUpload(fromCamera: false),
                  );

                  if (stackButtons) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        cameraBtn,
                        const SizedBox(height: 10),
                        galleryBtn,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: cameraBtn),
                      const SizedBox(width: 12),
                      Expanded(child: galleryBtn),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _isUploading
                        ? null
                        : () => setState(() => _showUrlField = !_showUrlField),
                    icon: const Icon(Icons.link_rounded, size: 18),
                    label: Text(
                      isBn ? 'ছবির HTTPS লিংক দিন' : 'Use image URL',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (hasCurrentPhoto)
                    TextButton.icon(
                      onPressed: _isUploading
                          ? null
                          : () => _persistAndClose(''),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: AppColors.errorRed,
                      ),
                      label: Text(
                        _isCover
                            ? (isBn ? 'ব্যানার সরান' : 'Remove banner')
                            : (isBn ? 'ছবি সরান' : 'Remove photo'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.errorRed,
                        ),
                      ),
                    ),
                ],
              ),
              if (_showUrlField) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                          hintText: 'https://...',
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isUploading
                          ? null
                          : () {
                              final raw = _urlController.text.trim();
                              final uri = Uri.tryParse(raw);
                              if (uri == null || !uri.isScheme('https')) {
                                UiFeedbackHelper.showError(
                                  context,
                                  'Enter a valid https:// image URL.',
                                );
                                return;
                              }
                              _persistAndClose(raw);
                            },
                      child: Text(isBn ? 'সেভ' : 'Apply'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
