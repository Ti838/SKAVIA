import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../models/radar_technician.dart';
import 'radar_map_controls.dart';

enum SkaviaMapStyle { street, satellite, dark }

/// Interactive Google-style street, satellite, and dark map canvas widget
/// powered by free Retina CartoDB & Esri World Imagery tiles.
class RadarMapCanvas extends StatefulWidget {
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
  State<RadarMapCanvas> createState() => _RadarMapCanvasState();
}

class _RadarMapCanvasState extends State<RadarMapCanvas> {
  SkaviaMapStyle? _selectedStyle;

  SkaviaMapStyle _effectiveStyle(BuildContext context) {
    if (_selectedStyle != null) return _selectedStyle!;
    return Theme.of(context).brightness == Brightness.dark
        ? SkaviaMapStyle.dark
        : SkaviaMapStyle.street;
  }

  void _cycleMapStyle(BuildContext context) {
    final current = _effectiveStyle(context);
    final next = switch (current) {
      SkaviaMapStyle.street => SkaviaMapStyle.satellite,
      SkaviaMapStyle.satellite => SkaviaMapStyle.dark,
      SkaviaMapStyle.dark => SkaviaMapStyle.street,
    };
    setState(() => _selectedStyle = next);
  }

  String _styleLabel(SkaviaMapStyle style) {
    return switch (style) {
      SkaviaMapStyle.street => widget.isBn ? 'স্ট্রিট ম্যাপ' : 'Street',
      SkaviaMapStyle.satellite => widget.isBn ? 'স্যাটেলাইট' : 'Satellite',
      SkaviaMapStyle.dark => widget.isBn ? 'ডার্ক ম্যাপ' : 'Dark',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    final activeStyle = _effectiveStyle(context);

    return Stack(
      children: [
        FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: widget.userPosition,
            initialZoom: widget.currentZoom,
            minZoom: 4.0,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onTap: widget.onMapTap,
          ),
          children: [
            // Base Tile Layer — 100% free, no API key required
            // Street: OSM Standard | Dark: Stadia Smooth Dark | Satellite: Esri World Imagery
            if (activeStyle == SkaviaMapStyle.satellite) ...[
              TileLayer(
                urlTemplate:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.skavia.app',
                maxZoom: 20,
              ),
            ] else if (activeStyle == SkaviaMapStyle.dark)
              TileLayer(
                // CartoDB DarkMatter — 100% free, no API key, crisp dark street tiles
                urlTemplate:
                    'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                retinaMode: RetinaMode.isHighDensity(context),
                userAgentPackageName: 'com.skavia.app',
                maxZoom: 19,
              )
            else
              TileLayer(
                // CartoDB Voyager / OSM fallback — clean street map with zero watermark
                urlTemplate:
                    'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                retinaMode: RetinaMode.isHighDensity(context),
                userAgentPackageName: 'com.skavia.app',
                maxZoom: 19,
              ),

            // Live Markers (Custom Pin, Google-Style Blue GPS Dot, Real Technicians)
            MarkerLayer(
              markers: [
                if (widget.selectedCustomPoint != null)
                  Marker(
                    point: widget.selectedCustomPoint!,
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
                  point: widget.userPosition,
                  width: 52,
                  height: 52,
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.isBn
                                ? 'আপনার আসল জিপিএস লোকেশন: ${widget.locationZone}'
                                : 'Your Live GPS Location: ${widget.locationZone}',
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
                            color: const Color(0xFF1A73E8)
                                .withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A73E8),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
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
                ...widget.filteredTechnicians.map((tech) {
                  final isSelected = widget.selectedTech?.id == tech.id;
                  return Marker(
                    point: LatLng(tech.latitude, tech.longitude),
                    width: isSelected ? 56 : 46,
                    height: isSelected ? 56 : 46,
                    child: GestureDetector(
                      onTap: () => widget.onTechnicianTap(tech),
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

        // Floating Controls (Map Layer Switcher, Recenter, Zoom)
        Positioned(
          top: 14,
          right: 14,
          child: RadarMapControls(
            isLocatingUser: widget.isLocatingUser,
            onRecenter: widget.onRecenter,
            onZoomIn: widget.onZoomIn,
            onZoomOut: widget.onZoomOut,
            onCycleLayer: () => _cycleMapStyle(context),
            layerLabel:
                '${widget.isBn ? "ম্যাপ ধরন" : "Map Style"}: ${_styleLabel(activeStyle)}',
          ),
        ),

        // Top-Left Floating Status & Active Map Style Pills
        Positioned(
          top: 14,
          left: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
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
                      '${widget.filteredTechnicians.length} ${widget.isBn ? "কারিগর অনলাইন" : "Pros Online"}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _cycleMapStyle(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.cardBg.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(14),
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
                      Icon(
                        activeStyle == SkaviaMapStyle.satellite
                            ? Icons.satellite_alt_rounded
                            : (activeStyle == SkaviaMapStyle.dark
                                  ? Icons.dark_mode_rounded
                                  : Icons.map_rounded),
                        size: 13,
                        color: tokens.brandAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _styleLabel(activeStyle),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Compact OpenStreetMap / CARTO / Esri Attribution Badge
        Positioned(
          left: 10,
          bottom: 8,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                activeStyle == SkaviaMapStyle.satellite
                    ? '© Esri · © OpenStreetMap'
                    : activeStyle == SkaviaMapStyle.dark
                        ? '© Stadia Maps · © OpenStreetMap'
                        : '© OpenStreetMap contributors',
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
