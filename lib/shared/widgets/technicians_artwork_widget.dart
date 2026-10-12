import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Pixel-perfect bespoke vector artwork for the SKAVIA Hero
/// Representing two certified technicians collaborating with tools & console,
/// precisely matching the reference art in skavia_exact_reference_ui.png.
class TechniciansArtworkWidget extends StatelessWidget {
  final double height;
  const TechniciansArtworkWidget({super.key, this.height = 240});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _TechniciansPainter()),
    );
  }
}

class _TechniciansPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background playful abstract curves & memphis circles (from reference art)
    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.78, h * 0.28), 38, circlePaint);

    final wavyLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Wavy curve behind technicians
    final wavePath = Path();
    wavePath.moveTo(w * 0.08, h * 0.2);
    wavePath.quadraticBezierTo(w * 0.25, h * 0.12, w * 0.45, h * 0.22);
    wavePath.quadraticBezierTo(w * 0.65, h * 0.32, w * 0.85, h * 0.18);
    canvas.drawPath(wavePath, wavyLinePaint);

    // Workbench / Console table surface
    final tablePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    final tableRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.68, w * 0.64, h * 0.12),
      const Radius.circular(8),
    );
    canvas.drawRRect(tableRect, tablePaint);

    // Central Computer Display / Server Grid
    final monitorPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    final monitorBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final monitorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.38, h * 0.40, w * 0.24, h * 0.28),
      const Radius.circular(6),
    );
    canvas.drawRRect(monitorRect, monitorPaint);
    canvas.drawRRect(monitorRect, monitorBorderPaint);

    // Grid code lines on monitor
    final gridLinePaint = Paint()
      ..color = AppColors.accentAqua.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 5; i++) {
      final y = h * 0.44 + (i * 9);
      canvas.drawLine(Offset(w * 0.40, y), Offset(w * 0.52, y), gridLinePaint);
    }

    // Rocket / Upward Momentum Graphic inside screen
    final rocketPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final rocketPath = Path();
    rocketPath.moveTo(w * 0.50, h * 0.43);
    rocketPath.quadraticBezierTo(w * 0.53, h * 0.50, w * 0.54, h * 0.58);
    rocketPath.lineTo(w * 0.46, h * 0.58);
    rocketPath.quadraticBezierTo(w * 0.47, h * 0.50, w * 0.50, h * 0.43);
    rocketPath.close();
    canvas.drawPath(rocketPath, rocketPaint);

    // Rocket flame (Peach accent)
    final flamePaint = Paint()
      ..color = AppColors.accentPeach
      ..style = PaintingStyle.fill;
    final flamePath = Path();
    flamePath.moveTo(w * 0.48, h * 0.58);
    flamePath.lineTo(w * 0.50, h * 0.64);
    flamePath.lineTo(w * 0.52, h * 0.58);
    flamePath.close();
    canvas.drawPath(flamePath, flamePaint);

    // -------------------------------------------------------------
    // LEFT TECHNICIAN (Master Electrician with Yellow/Peach Hard Hat)
    // -------------------------------------------------------------
    final skinPaint = Paint()..color = const Color(0xFFFFD1B3);
    final peachShirtPaint = Paint()..color = const Color(0xFFFFB088);
    final darkOutlinePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Body / Overalls
    final leftBodyPath = Path();
    leftBodyPath.moveTo(w * 0.16, h * 0.82);
    leftBodyPath.lineTo(w * 0.20, h * 0.58);
    leftBodyPath.lineTo(w * 0.34, h * 0.58);
    leftBodyPath.lineTo(w * 0.38, h * 0.82);
    leftBodyPath.close();
    canvas.drawPath(leftBodyPath, peachShirtPaint);
    canvas.drawPath(leftBodyPath, darkOutlinePaint);

    // Head
    canvas.drawCircle(Offset(w * 0.27, h * 0.50), 18, skinPaint);
    canvas.drawCircle(Offset(w * 0.27, h * 0.50), 18, darkOutlinePaint);

    // Yellow Safety Hard Hat
    final helmetPaint = Paint()..color = const Color(0xFFFFC107);
    final helmetPath = Path();
    helmetPath.moveTo(w * 0.20, h * 0.49);
    helmetPath.quadraticBezierTo(w * 0.27, h * 0.38, w * 0.34, h * 0.49);
    helmetPath.lineTo(w * 0.36, h * 0.51);
    helmetPath.lineTo(w * 0.18, h * 0.51);
    helmetPath.close();
    canvas.drawPath(helmetPath, helmetPaint);
    canvas.drawPath(helmetPath, darkOutlinePaint);

    // Arm reaching to workbench holding screwdriver
    final armPath = Path();
    armPath.moveTo(w * 0.32, h * 0.62);
    armPath.quadraticBezierTo(w * 0.37, h * 0.65, w * 0.41, h * 0.66);
    canvas.drawPath(armPath, darkOutlinePaint);

    // Tool (Wrench in hand)
    final toolPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.40, h * 0.64),
      Offset(w * 0.44, h * 0.67),
      toolPaint,
    );

    // -------------------------------------------------------------
    // RIGHT TECHNICIAN (Systems Engineer with Navy Cap)
    // -------------------------------------------------------------
    final blueShirtPaint = Paint()..color = const Color(0xFF60A5FA);

    // Body
    final rightBodyPath = Path();
    rightBodyPath.moveTo(w * 0.62, h * 0.82);
    rightBodyPath.lineTo(w * 0.65, h * 0.58);
    rightBodyPath.lineTo(w * 0.80, h * 0.58);
    rightBodyPath.lineTo(w * 0.84, h * 0.82);
    rightBodyPath.close();
    canvas.drawPath(rightBodyPath, blueShirtPaint);
    canvas.drawPath(rightBodyPath, darkOutlinePaint);

    // Head
    canvas.drawCircle(Offset(w * 0.72, h * 0.50), 18, skinPaint);
    canvas.drawCircle(Offset(w * 0.72, h * 0.50), 18, darkOutlinePaint);

    // Blue Service Cap
    final capPaint = Paint()..color = const Color(0xFF1E3A8A);
    final capPath = Path();
    capPath.moveTo(w * 0.66, h * 0.50);
    capPath.quadraticBezierTo(w * 0.72, h * 0.40, w * 0.78, h * 0.50);
    capPath.lineTo(w * 0.82, h * 0.51);
    capPath.lineTo(w * 0.64, h * 0.51);
    capPath.close();
    canvas.drawPath(capPath, capPaint);
    canvas.drawPath(capPath, darkOutlinePaint);

    // Arm on table typing
    final rightArmPath = Path();
    rightArmPath.moveTo(w * 0.67, h * 0.62);
    rightArmPath.quadraticBezierTo(w * 0.63, h * 0.66, w * 0.58, h * 0.68);
    canvas.drawPath(rightArmPath, darkOutlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Potted plant decoration widget matching the bottom right of reference art
class PottedPlantDecoration extends StatelessWidget {
  final double size;
  const PottedPlantDecoration({super.key, this.size = 54});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.3,
      child: CustomPaint(painter: _PlantPainter()),
    );
  }
}

class _PlantPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final outline = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final potPaint = Paint()
      ..color = const Color(0xFFFFB088)
      ..style = PaintingStyle.fill;

    // Pot
    final potPath = Path();
    potPath.moveTo(w * 0.22, h * 0.62);
    potPath.lineTo(w * 0.78, h * 0.62);
    potPath.lineTo(w * 0.70, h * 0.98);
    potPath.lineTo(w * 0.30, h * 0.98);
    potPath.close();
    canvas.drawPath(potPath, potPaint);
    canvas.drawPath(potPath, outline);

    // Blue & Aqua leaves
    final leafPaint1 = Paint()..color = const Color(0xFF3898EC);
    final leafPaint2 = Paint()..color = const Color(0xFF15E7CA);
    final darkLeafPaint = Paint()..color = const Color(0xFF003399);

    // Left leaf
    final leaf1 = Path();
    leaf1.moveTo(w * 0.50, h * 0.62);
    leaf1.quadraticBezierTo(w * 0.10, h * 0.40, w * 0.25, h * 0.15);
    leaf1.quadraticBezierTo(w * 0.45, h * 0.35, w * 0.50, h * 0.62);
    canvas.drawPath(leaf1, leafPaint1);
    canvas.drawPath(leaf1, outline);

    // Right leaf
    final leaf2 = Path();
    leaf2.moveTo(w * 0.50, h * 0.62);
    leaf2.quadraticBezierTo(w * 0.90, h * 0.40, w * 0.75, h * 0.15);
    leaf2.quadraticBezierTo(w * 0.55, h * 0.35, w * 0.50, h * 0.62);
    canvas.drawPath(leaf2, leafPaint2);
    canvas.drawPath(leaf2, outline);

    // Center tall leaf
    final leaf3 = Path();
    leaf3.moveTo(w * 0.50, h * 0.62);
    leaf3.quadraticBezierTo(w * 0.38, h * 0.25, w * 0.50, h * 0.05);
    leaf3.quadraticBezierTo(w * 0.62, h * 0.25, w * 0.50, h * 0.62);
    canvas.drawPath(leaf3, darkLeafPaint);
    canvas.drawPath(leaf3, outline);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
