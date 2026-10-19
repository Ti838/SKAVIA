import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Floating zoom and GPS recenter controls for radar map sheets.
class RadarMapControls extends StatelessWidget {
  final bool isLocatingUser;
  final VoidCallback onRecenter;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const RadarMapControls({
    super.key,
    required this.isLocatingUser,
    required this.onRecenter,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  Widget _buildButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.primaryRoyal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(
          context: context,
          icon: isLocatingUser
              ? Icons.hourglass_top_rounded
              : Icons.my_location_rounded,
          tooltip: 'Recenter to My GPS Location',
          onTap: onRecenter,
        ),
        const SizedBox(height: 8),
        _buildButton(
          context: context,
          icon: Icons.add,
          tooltip: 'Zoom In',
          onTap: onZoomIn,
        ),
        const SizedBox(height: 8),
        _buildButton(
          context: context,
          icon: Icons.remove,
          tooltip: 'Zoom Out',
          onTap: onZoomOut,
        ),
      ],
    );
  }
}
