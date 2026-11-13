import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../models/radar_technician.dart';
import 'radar_map_controls.dart';

/// Interactive OpenStreetMap canvas widget with user pin, tap marker, and technician dots.
class RadarMapCanvas extends StatelessWidget {
  final MapController mapController;
  final LatLng userPosition;
  final double currentZoom;
  final LatLng? selectedCustomPoint;
  final List<RadarTechnician> filteredTechnicians;
  final RadarTechnician? selectedTech;
  final String locationZone;
  final bool isBn;
  final bool isLocatingUser;
  final void Function(TapPosition, LatLng) onMapTap;
  final ValueChanged<RadarTechnician> onTechnicianTap;
  final VoidCallback onRecenter;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const RadarMapCanvas({
    super.key,
    required this.mapController,
    required this.userPosition,
    required this.currentZoom,
    required this.selectedCustomPoint,
    required this.filteredTechnicians,
    required this.selectedTech,
    required this.locationZone,
    required this.isBn,
    required this.isLocatingUser,
    required this.onMapTap,
    required this.onTechnicianTap,
    required this.onRecenter,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: userPosition,
            initialZoom: currentZoom,
            minZoom: 4.0,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onTap: onMapTap,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.skavia.app',
              maxZoom: 19,
            ),
            MarkerLayer(
              markers: [
                if (selectedCustomPoint != null)
                  Marker(
                    point: selectedCustomPoint!,
                    width: 50,
                    height: 50,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: AppColors.accentCoral,
                          size: 38,
                        ),
                      ],
                    ),
                  ),
                Marker(
                  point: userPosition,
                  width: 52,
                  height: 52,
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isBn
                                ? 'আপনার আসল জিপিএস লোকেশন'
                                : 'Your Live GPS Location: $locationZone',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryRoyal.withValues(
                              alpha: 0.22,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.primaryRoyal,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ...filteredTechnicians.map((tech) {
                  final isSelected = selectedTech?.id == tech.id;
                  return Marker(
                    point: LatLng(tech.latitude, tech.longitude),
                    width: isSelected ? 56 : 46,
                    height: isSelected ? 56 : 46,
                    child: GestureDetector(
                      onTap: () => onTechnicianTap(tech),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryRoyal
                              : tokens.cardBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : tech.color,
                            width: isSelected ? 3 : 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          tech.icon,
                          color: isSelected ? Colors.white : tech.color,
                          size: isSelected ? 26 : 20,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),

        // Floating Controls (Recenter, Zoom)
        Positioned(
          top: 14,
          right: 14,
          child: RadarMapControls(
            isLocatingUser: isLocatingUser,
            onRecenter: onRecenter,
            onZoomIn: onZoomIn,
            onZoomOut: onZoomOut,
          ),
        ),

        // Floating Status Pill
        Positioned(
          top: 14,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: tokens.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tokens.border),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.successGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${filteredTechnicians.length} ${isBn ? "কারিগর অনলাইন" : "Pros Online"}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

