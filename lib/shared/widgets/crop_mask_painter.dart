import 'package:flutter/material.dart';

/// Canvas painter for rendering a dimmed backdrop with a circular or rounded rectangular cutout.
class CropMaskPainter extends CustomPainter {
  final double cropWidth;
  final double cropHeight;
  final bool isCircular;

  const CropMaskPainter({
    required this.cropWidth,
    required this.cropHeight,
    required this.isCircular,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final frameRect = Rect.fromCenter(
      center: center,
      width: cropWidth,
      height: cropHeight,
    );

    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path();
    if (isCircular) {
      cutoutPath.addOval(frameRect);
    } else {
      cutoutPath.addRRect(
        RRect.fromRectAndRadius(frameRect, const Radius.circular(14)),
      );
    }

    final maskPath = Path.combine(
      PathOperation.difference,
      fullPath,
      cutoutPath,
    );
    canvas.drawPath(
      maskPath,
      Paint()..color = const Color(0xAA000000),
    );

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    if (isCircular) {
      canvas.drawOval(frameRect, borderPaint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(frameRect, const Radius.circular(14)),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CropMaskPainter oldDelegate) {
    return oldDelegate.cropWidth != cropWidth ||
        oldDelegate.cropHeight != cropHeight ||
        oldDelegate.isCircular != isCircular;
  }
}
