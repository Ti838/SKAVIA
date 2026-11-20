import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../customer/presentation/widgets/avatar_picker_sheet.dart';
import '../../data/models/user_profile_model.dart';

/// Card in EditDetailedProfileScreen displaying current avatar with upload/change triggers.
class ProfileAvatarPickerCard extends StatelessWidget {
  final UserProfileModel? profile;
  final String? avatarUrl;
  final ValueChanged<String> onAvatarSelected;

  const ProfileAvatarPickerCard({
    super.key,
    required this.profile,
    required this.avatarUrl,
    required this.onAvatarSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isBn = context.isBengali;

    final effectiveAvatar = avatarUrl ?? profile?.avatarUrl;
    final effectiveName = profile?.fullName.isNotEmpty == true &&
            profile!.fullName != 'SKAVIA Member'
        ? profile!.fullName
        : 'SKAVIA Member';

    void openAvatarPicker() {
      AvatarPickerSheet.show(
        context,
        currentAvatarUrl: effectiveAvatar,
        userId: profile?.id,
        slot: ProfileMediaSlot.avatar,
        onAvatarSelected: onAvatarSelected,
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                imageUrl: effectiveAvatar,
                name: effectiveName,
                radius: 32,
                isVerified: profile?.verificationStatus == 'verified',
                onTap: openAvatarPicker,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      effectiveName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile?.email.isNotEmpty == true
                          ? profile!.email
                          : (isBn
                              ? 'ক্যামেরা বা গ্যালারি থেকে ছবি আপলোড করুন'
                              : 'Tap photo to upload from camera or gallery'),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: openAvatarPicker,
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        size: 16,
                      ),
                      label: Text(
                        isBn ? 'ছবি পরিবর্তন করুন' : 'Change Photo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
