import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../shared/widgets/skavia_brand_image.dart';

/// Lightweight, 60fps continuous animated brand showcase widget.
/// Highlights SKAVIA's 8 core operational branches with soft ambient lighting,
/// subtle harmonic float micro-motion, and full accessibility (reduced-motion safe).
class AnimatedServiceShowcase extends StatefulWidget {
  final double height;

  const AnimatedServiceShowcase({super.key, this.height = 240});

  @override
  State<AnimatedServiceShowcase> createState() =>
      _AnimatedServiceShowcaseState();
}

class _AnimatedServiceShowcaseState extends State<AnimatedServiceShowcase>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<_ShowcaseCategory> _categories = [
    _ShowcaseCategory(
      label: 'Electrical & Power',
      icon: Icons.bolt_rounded,
      color: Color(0xFF003399),
      accentColor: Color(0xFF3898EC),
    ),
    _ShowcaseCategory(
      label: 'Plumbing & Sanitary',
      icon: Icons.plumbing_rounded,
      color: Color(0xFF0284C7),
      accentColor: Color(0xFF38BDF8),
    ),
    _ShowcaseCategory(
      label: 'AC & HVAC Cooling',
      icon: Icons.ac_unit_rounded,
      color: Color(0xFF0D9488),
      accentColor: Color(0xFF15E7CA),
    ),
    _ShowcaseCategory(
      label: 'IT, Software & Creative',
      icon: Icons.code_rounded,
      color: Color(0xFF4F46E5),
      accentColor: Color(0xFF818CF8),
    ),
    _ShowcaseCategory(
      label: 'Civil & Carpentry',
      icon: Icons.construction_rounded,
      color: Color(0xFFD97706),
      accentColor: Color(0xFFFBBF24),
    ),
    _ShowcaseCategory(
      label: 'Automotive Mechanics',
      icon: Icons.directions_car_rounded,
      color: Color(0xFFDC2626),
      accentColor: Color(0xFFF87171),
    ),
    _ShowcaseCategory(
      label: 'Industrial Machinery',
      icon: Icons.precision_manufacturing_rounded,
      color: Color(0xFF7C3AED),
      accentColor: Color(0xFFA78BFA),
    ),
    _ShowcaseCategory(
      label: 'Appliance & Home Care',
      icon: Icons.home_repair_service_rounded,
      color: Color(0xFF059669),
      accentColor: Color(0xFF34D399),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final cardBg = isDark ? const Color(0xFF0B1426) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE2E8F0);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = reduceMotion ? 0.0 : _controller.value;
          final angle = progress * 2 * math.pi;

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Ambient glow effect
              Positioned(
                child: Container(
                  width: 220,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF3898EC)
                            .withValues(alpha: isDark ? 0.20 : 0.14),
                        const Color(0xFF15E7CA)
                            .withValues(alpha: isDark ? 0.10 : 0.06),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),

              // Central Hub Card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.4)
                          : const Color(0xFF003399).withValues(alpha: 0.08),
                      blurRadius: 28,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Official SKAVIA Emblem
                    Container(
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor),
                      ),
                      child: SkaviaBrandImage(
                        assetPath: AppAssets.emblem,
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.engineering_rounded,
                          size: 24,
                          color: Color(0xFF003399),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'SKAVIA Network',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: primaryTextColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: isDark ? 0.20 : 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.4),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Active',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '8 Verified Specialization Branches',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Floating Satellite Category Pills (4 floating around hub)
              ..._buildFloatingPills(
                context,
                angle: angle,
                isDark: isDark,
                borderColor: borderColor,
                cardBg: cardBg,
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildFloatingPills(
    BuildContext context, {
    required double angle,
    required bool isDark,
    required Color borderColor,
    required Color cardBg,
  }) {
    // 4 prominent dynamic categories with smooth floating physics
    final selectedIndices = [0, 2, 3, 5]; // Electrical, AC/HVAC, IT, Automotive
    final widgets = <Widget>[];

    // Floating offsets and positions
    final positions = [
      // Top Left: Electrical & Power
      _PillPosition(top: 14, left: 18, phase: 0.0, index: selectedIndices[0]),
      // Top Right: AC & HVAC Cooling
      _PillPosition(
        top: 18,
        right: 18,
        phase: math.pi / 2,
        index: selectedIndices[1],
      ),
      // Bottom Left: IT & Software
      _PillPosition(
        bottom: 18,
        left: 20,
        phase: math.pi,
        index: selectedIndices[2],
      ),
      // Bottom Right: Automotive Mechanics
      _PillPosition(
        bottom: 14,
        right: 20,
        phase: 3 * math.pi / 2,
        index: selectedIndices[3],
      ),
    ];

    for (final pos in positions) {
      final cat = _categories[pos.index];
      final floatY = math.sin(angle + pos.phase) * 6.0;

      widgets.add(
        Positioned(
          top: pos.top != null ? pos.top! + floatY : null,
          bottom: pos.bottom != null ? pos.bottom! - floatY : null,
          left: pos.left,
          right: pos.right,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: cardBg.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cat.accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : cat.color.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: isDark ? 0.25 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(cat.icon, size: 13, color: cat.accentColor),
                ),
                const SizedBox(width: 6),
                Text(
                  cat.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}

class _ShowcaseCategory {
  final String label;
  final IconData icon;
  final Color color;
  final Color accentColor;

  const _ShowcaseCategory({
    required this.label,
    required this.icon,
    required this.color,
    required this.accentColor,
  });
}

class _PillPosition {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double phase;
  final int index;

  const _PillPosition({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.phase,
    required this.index,
  });
}
