import 'dart:async';

import 'package:flutter/material.dart';

/// Luxury, Apple/Stripe-grade Hero Showcase Widget for the SKAVIA Welcome screen.
/// Automatically cycles through the 4 core trust and capability pillars of SKAVIA:
/// 1. 500+ Background-Checked Specialists
/// 2. 4-Digit Handshake Arrival OTP
/// 3. Atomic Escrow Payment Protection
/// 4. Live Street Map & Radar Dispatch
class AnimatedServiceShowcase extends StatefulWidget {
  final double height;

  const AnimatedServiceShowcase({super.key, this.height = 180});

  @override
  State<AnimatedServiceShowcase> createState() =>
      _AnimatedServiceShowcaseState();
}

class _AnimatedServiceShowcaseState extends State<AnimatedServiceShowcase> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  static const List<_ShowcaseItem> _items = [
    _ShowcaseItem(
      title: '500+ Verified Specialists',
      subtitle: 'Electrical, AC & HVAC, Civil, Plumbing & IT',
      badge: '★ 4.9 Service Rating',
      secondaryBadge: 'Background-Checked',
      icon: Icons.verified_user_rounded,
      primaryColor: Color(0xFF003399),
      accentColor: Color(0xFF3898EC),
    ),
    _ShowcaseItem(
      title: '4-Digit Handshake OTP',
      subtitle: 'Technicians enter only after on-site OTP verification',
      badge: 'Zero Unauthorized Entry',
      secondaryBadge: 'Military-Grade',
      icon: Icons.pin_rounded,
      primaryColor: Color(0xFF4F46E5),
      accentColor: Color(0xFF818CF8),
    ),
    _ShowcaseItem(
      title: 'Atomic Escrow Protection',
      subtitle: 'Payments held securely until 100% satisfied',
      badge: '90/10 Escrow Gate',
      secondaryBadge: 'Zero Risk',
      icon: Icons.shield_rounded,
      primaryColor: Color(0xFF0D9488),
      accentColor: Color(0xFF14B8A6),
    ),
    _ShowcaseItem(
      title: 'Live Street Map & Radar',
      subtitle: 'Real-time GPS dispatch with under-30m arrival',
      badge: 'Nationwide Tracking',
      secondaryBadge: 'Instant Dispatch',
      icon: Icons.radar_rounded,
      primaryColor: Color(0xFFD97706),
      accentColor: Color(0xFFFBBF24),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoCycle();
  }

  void _startAutoCycle() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 3800), (timer) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _items.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardBorder = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE2E8F0);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.40)
        : const Color(0xFF003399).withValues(alpha: 0.06);

    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: [
            // Top Status Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : const Color(0xFFF8FAFC),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFF1F5F9),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'SKAVIA Network Ecosystem',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFF003399),
                      letterSpacing: 0.4,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '8 Branches',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView Spotlight Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Icon Orb
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                item.primaryColor,
                                item.accentColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: item.primaryColor.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            item.icon,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Right Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item.accentColor.withValues(
                                        alpha: isDark ? 0.18 : 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: item.accentColor.withValues(
                                          alpha: 0.35,
                                        ),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      item.badge,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? item.accentColor
                                            : item.primaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      '• ${item.secondaryBadge}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white54
                                            : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Page Indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_items.length, (index) {
                  final isActive = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 18 : 6,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isActive
                          ? (isDark
                              ? const Color(0xFF3898EC)
                              : const Color(0xFF003399))
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.15)
                              : const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShowcaseItem {
  final String title;
  final String subtitle;
  final String badge;
  final String secondaryBadge;
  final IconData icon;
  final Color primaryColor;
  final Color accentColor;

  const _ShowcaseItem({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.secondaryBadge,
    required this.icon,
    required this.primaryColor,
    required this.accentColor,
  });
}
