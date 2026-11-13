import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/extensions/context_extensions.dart';

/// Reusable user avatar with verified badge and safe network image fallback.
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
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Widget _buildInitialsFallback(BuildContext context) {
    final tokens = context.skavia;
    return Center(
      child: Text(
        _initials,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.75,
          color: tokens.brandAccent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final hasValidUrl =
        imageUrl != null &&
        imageUrl!.trim().isNotEmpty &&
        (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'));

    final diameter = radius * 2;
    Widget avatar = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: AppColors.primarySky.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasValidUrl
          ? Image.network(
              imageUrl!.trim(),
              width: diameter,
              height: diameter,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildInitialsFallback(context),
            )
          : _buildInitialsFallback(context),
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
                decoration: BoxDecoration(
                  color: tokens.cardBg,
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
                  border: Border.all(color: tokens.cardBg, width: 1.5),
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
