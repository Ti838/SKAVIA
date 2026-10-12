import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// High-performance GPU CustomPainter widget rendering a live vector radar map of Dhaka,
/// displaying user GPS pulse pin and nearby active trade technicians (⚡, ❄️, 🔧).
class RadarMapArtworkWidget extends StatefulWidget {
  final String locationZone;
  final int activeTechCount;
  final VoidCallback? onExpand;

  const RadarMapArtworkWidget({
    super.key,
    required this.locationZone,
    this.activeTechCount = 18,
    this.onExpand,
  });

  @override
  State<RadarMapArtworkWidget> createState() => _RadarMapArtworkWidgetState();
}

class _RadarMapArtworkWidgetState extends State<RadarMapArtworkWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 148,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36), // Deep Night Radar Slate
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF003399).withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Animated Vector Canvas
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 148),
                  painter: _RadarMapPainter(
                    animationValue: _pulseController.value,
                  ),
                );
              },
            ),

            // Subtle vignette & grid gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0F1E36).withValues(alpha: 0.2),
                    const Color(0xFF0F1E36).withValues(alpha: 0.75),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Top Status Badge: Zone & Active Count
            Positioned(
              top: 12,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accentAqua,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.locationZone} Radar • ${widget.activeTechCount} Pros Active',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expand Map Action Button
            if (widget.onExpand != null)
              Positioned(
                top: 10,
                right: 12,
                child: GestureDetector(
                  onTap: widget.onExpand,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySky.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primarySky.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fullscreen_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Radar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Bottom Info Chip: Avg Dispatch Time
            Positioned(
              bottom: 12,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildTechMarkerChip(
                        Icons.electric_bolt_rounded,
                        AppColors.accentPeach,
                        'Electricians',
                      ),
                      const SizedBox(width: 6),
                      _buildTechMarkerChip(
                        Icons.ac_unit_rounded,
                        AppColors.primarySky,
                        'HVAC',
                      ),
                      const SizedBox(width: 6),
                      _buildTechMarkerChip(
                        Icons.plumbing_rounded,
                        AppColors.accentAqua,
                        'Plumbers',
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '~15 min arrival',
                      style: TextStyle(
                        color: AppColors.accentAqua,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechMarkerChip(IconData icon, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarMapPainter extends CustomPainter {
  final double animationValue;

  _RadarMapPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.48, h * 0.52);

    // 1. Draw Street Grids (Vector Roads)
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Horizontal & diagonal road avenues
    final path = Path();
    path.moveTo(0, h * 0.35);
    path.lineTo(w, h * 0.42);
    path.moveTo(0, h * 0.72);
    path.lineTo(w, h * 0.65);
    path.moveTo(w * 0.22, 0);
    path.lineTo(w * 0.38, h);
    path.moveTo(w * 0.68, 0);
    path.lineTo(w * 0.78, h);
    path.moveTo(w * 0.1, h * 0.85);
    path.quadraticBezierTo(w * 0.5, h * 0.4, w * 0.9, h * 0.9);
    canvas.drawPath(path, roadPaint);

    // 2. Concentric Radar Pulse Rings
    for (int i = 1; i <= 3; i++) {
      final ringRadius = (i * 36.0) + (animationValue * 24.0) % 72.0;
      final opacity = (1.0 - (ringRadius / 110.0)).clamp(0.0, 0.4);
      final ringPaint = Paint()
        ..color = AppColors.primarySky.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(center, ringRadius, ringPaint);
    }

    // 3. Radar Beam Sector Sweep
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: FractionalOffset(center.dx / w, center.dy / h),
        startAngle: 0.0,
        endAngle: math.pi * 2,
        colors: [
          Colors.transparent,
          AppColors.accentAqua.withValues(alpha: 0.0),
          AppColors.accentAqua.withValues(alpha: 0.16),
        ],
        stops: const [0.0, 0.75, 1.0],
        transform: GradientRotation(animationValue * math.pi * 2),
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawCircle(center, 90, sweepPaint);

    // 4. Draw Center User Pin (📍 Hardware GPS)
    final userPulseRadius = 8.0 + (animationValue * 12.0);
    final userPulsePaint = Paint()
      ..color = AppColors.primarySky.withValues(
        alpha: (1.0 - animationValue).clamp(0.0, 0.6),
      )
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, userPulseRadius, userPulsePaint);

    final userCorePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5.0, userCorePaint);

    final userDotPaint = Paint()
      ..color = AppColors.primaryRoyal
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2.5, userDotPaint);

    // 5. Draw Nearby Active Technicians (Pins)
    _drawTechPin(
      canvas,
      Offset(w * 0.28, h * 0.42),
      AppColors.accentPeach,
      '⚡',
    );
    _drawTechPin(
      canvas,
      Offset(w * 0.72, h * 0.38),
      AppColors.primarySky,
      '❄️',
    );
    _drawTechPin(
      canvas,
      Offset(w * 0.62, h * 0.72),
      AppColors.accentAqua,
      '🔧',
    );
    _drawTechPin(
      canvas,
      Offset(w * 0.18, h * 0.68),
      AppColors.accentPeach,
      '⚡',
    );
  }

  void _drawTechPin(Canvas canvas, Offset pos, Color color, String glyph) {
    // Halo glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 8.0, glowPaint);

    // Core circle
    final corePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 5.0, corePaint);

    // White dot inside
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 2.0, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarMapPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
