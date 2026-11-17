import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';

/// Floating map layer, zoom, and GPS recenter controls for radar map sheets.
class RadarMapControls extends StatelessWidget {
  final bool isLocatingUser;
  final VoidCallback onRecenter;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback? onCycleLayer;
  final String? layerLabel;

  const RadarMapControls({
    super.key,
    required this.isLocatingUser,
    required this.onRecenter,
    required this.onZoomIn,
    required this.onZoomOut,
    this.onCycleLayer,
    this.layerLabel,
  });

  Widget _buildButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final tokens = context.skavia;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: tokens.cardBg,
        shape: CircleBorder(side: BorderSide(color: tokens.border)),
        elevation: 3,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(icon, size: 20, color: tokens.brandAccent),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onCycleLayer != null) ...[
          _buildButton(
            context: context,
            icon: Icons.layers_rounded,
            tooltip: layerLabel ?? 'Switch Map Style (Street / Satellite / Dark)',
            onTap: onCycleLayer!,
          ),
          const SizedBox(height: 8),
        ],
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
