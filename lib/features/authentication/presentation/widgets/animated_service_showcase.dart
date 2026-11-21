import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../shared/widgets/skavia_brand_image.dart';

/// Professional, enterprise-grade service ecosystem showcase.
/// Displays SKAVIA's 8 core operational branches with dual-track flowing
/// micro-motion, edge fade gradients, and 100% collision-free responsive geometry.
class AnimatedServiceShowcase extends StatefulWidget {
  final double height;

  const AnimatedServiceShowcase({super.key, this.height = 190});

  @override
  State<AnimatedServiceShowcase> createState() =>
      _AnimatedServiceShowcaseState();
}

class _AnimatedServiceShowcaseState extends State<AnimatedServiceShowcase>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<_ShowcaseCategory> _row1Categories = [
    _ShowcaseCategory(
      label: 'Electrical & Power',
      icon: Icons.bolt_rounded,
      color: Color(0xFF003399),
      accentColor: Color(0xFF3898EC),
    ),
    _ShowcaseCategory(
      label: 'AC & HVAC Cooling',
      icon: Icons.ac_unit_rounded,
      color: Color(0xFF0D9488),
      accentColor: Color(0xFF15E7CA),
    ),
    _ShowcaseCategory(
      label: 'Plumbing & Sanitary',
      icon: Icons.plumbing_rounded,
      color: Color(0xFF0284C7),
      accentColor: Color(0xFF38BDF8),
    ),
    _ShowcaseCategory(
      label: 'IT, Software & Creative',
      icon: Icons.code_rounded,
      color: Color(0xFF4F46E5),
      accentColor: Color(0xFF818CF8),
    ),
  ];

  static const List<_ShowcaseCategory> _row2Categories = [
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
      duration: const Duration(seconds: 10),
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

    final bgColor = isDark ? const Color(0xFF05080F) : Colors.white;
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFE2E8F0);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Subtle Ambient Center Glow
          Container(
            width: 260,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF3898EC).withValues(alpha: isDark ? 0.18 : 0.10),
                  const Color(0xFF15E7CA).withValues(alpha: isDark ? 0.08 : 0.04),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // 2. Structured Layout: Verified Badge + Dual Flowing Category Rails
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top Platform Verified Capsule
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6.5),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: borderColor, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.35)
                          : const Color(0xFF003399).withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Official SKAVIA Emblem
                    Container(
                      width: 22,
                      height: 22,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor, width: 0.8),
                      ),
                      child: SkaviaBrandImage(
                        assetPath: AppAssets.emblem,
                        width: 16,
                        height: 16,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.engineering_rounded,
                          size: 14,
                          color: Color(0xFF003399),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SKAVIA Network',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3.5,
                      height: 3.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.white30 : Colors.black26,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      '8 Verified Branches',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 13),

              // Animated Dual Category Rows
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final progress = reduceMotion ? 0.0 : _controller.value;
                  final angle = progress * 2 * math.pi;

                  // Smooth organic sinusoidal offset (prevents clipping, zero collision)
                  final offset1 = reduceMotion ? 0.0 : math.sin(angle) * 28.0;
                  final offset2 = reduceMotion ? 0.0 : -math.sin(angle) * 28.0;

                  return Column(
                    children: [
                      // Track 1: Moving smoothly
                      Transform.translate(
                        offset: Offset(offset1, 0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 16),
                              ..._row1Categories.map(
                                (cat) => Padding(
                                  padding: const EdgeInsets.only(right: 8.5),
                                  child: _buildCategoryPill(
                                    cat,
                                    isDark: isDark,
                                    cardBg: cardBg,
                                    borderColor: borderColor,
                                    primaryTextColor: primaryTextColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 9),

                      // Track 2: Moving smoothly in reverse
                      Transform.translate(
                        offset: Offset(offset2, 0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 16),
                              ..._row2Categories.map(
                                (cat) => Padding(
                                  padding: const EdgeInsets.only(right: 8.5),
                                  child: _buildCategoryPill(
                                    cat,
                                    isDark: isDark,
                                    cardBg: cardBg,
                                    borderColor: borderColor,
                                    primaryTextColor: primaryTextColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),

          // 3. Left & Right Edge Luxury Fade Masks
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 28,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      bgColor,
                      bgColor.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 28,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      bgColor.withValues(alpha: 0.0),
                      bgColor,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(
    _ShowcaseCategory cat, {
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color primaryTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cat.accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : cat.color.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4.5),
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: isDark ? 0.25 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(cat.icon, size: 13, color: cat.accentColor),
          ),
          const SizedBox(width: 7),
          Text(
            cat.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
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
