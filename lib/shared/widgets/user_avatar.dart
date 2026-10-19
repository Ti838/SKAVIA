import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Reusable user avatar with verified badge and network image fallback.
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final bool isVerified;
  final bool isOnline;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 24,
    this.isVerified = false,
    this.isOnline = false,
    this.onTap,
  });

  String get _initials {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primarySky.withValues(alpha: 0.15),
      backgroundImage: imageUrl != null && imageUrl!.startsWith('http')
          ? NetworkImage(imageUrl!)
          : null,
      child: imageUrl == null || !imageUrl!.startsWith('http')
          ? Text(
              _initials,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.75,
                color: AppColors.primaryRoyal,
              ),
            )
          : null,
    );

    if (isVerified || isOnline) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          if (isVerified)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: AppColors.primarySky,
                  size: 14,
                ),
              ),
            ),
          if (isOnline && !isVerified)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }
}
