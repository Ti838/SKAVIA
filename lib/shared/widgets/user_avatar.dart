import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';

/// Reusable user avatar with verified badge and safe network image fallback.
/// Uses adaptive semantic tokens and always renders genuine user initials
/// when no profile image URL is present.
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
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed
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
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Text(
        _initials,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.72,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    final hasValidUrl =
        imageUrl != null &&
        imageUrl!.trim().isNotEmpty &&
        (imageUrl!.trim().startsWith('http://') ||
            imageUrl!.trim().startsWith('https://'));

    final diameter = radius * 2;
    Widget avatar = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        shape: BoxShape.circle,
        border: Border.all(color: tokens.border, width: 1),
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
                child: Icon(
                  Icons.verified_rounded,
                  color: tokens.tealAccent,
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
                  color: tokens.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: tokens.cardBg, width: 1.5),
                ),
              ),
            ),
        ],
      );
    }

    if (onTap != null) {
      return Semantics(
        button: true,
        label: name.trim().isEmpty ? 'User profile' : '$name profile',
        child: InkResponse(
          onTap: onTap,
          radius: radius + 8,
          child: avatar,
        ),
      );
    }
    return avatar;
  }
}
