import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/services/app_language_service.dart';
import '../../../core/services/location_service.dart';
import '../models/radar_technician.dart';
import 'radar_map_filter_bar.dart';
import 'radar_technician_card.dart';

export '../models/radar_technician.dart';

/// Real Interactive Google-Style Street Map Bottom Sheet
/// Powered by live OpenStreetMap street tiles, real GPS centering,
/// interactive pinch-to-zoom, technician markers, and direct Google Maps App navigation.
class RadarMapSheet extends StatefulWidget {
  final String locationZone;
  final Function(RadarTechnician tech)? onSelectTechnician;

  const RadarMapSheet({
    super.key,
    required this.locationZone,
    this.onSelectTechnician,
  });

  static void show(
    BuildContext context, {
    required String locationZone,
    Function(RadarTechnician)? onSelectTechnician,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RadarMapSheet(
        locationZone: locationZone,
        onSelectTechnician: onSelectTechnician,
      ),
    );
  }

  @override
  State<RadarMapSheet> createState() => _RadarMapSheetState();
}

class _RadarMapSheetState extends State<RadarMapSheet> {
  late final MapController _mapController;
  int _selectedRadiusKm = 5;
  String _selectedTradeFilter = 'All';
  RadarTechnician? _selectedTech;

  // Real Hardware GPS Location State
  LatLng _userPosition = const LatLng(
    23.7461,
    90.3742,
  ); // Default Dhanmondi, Dhaka
  bool _isLocatingUser = false;
  double _currentZoom = 13.5;

  late final List<RadarTechnician> _allTechnicians;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _allTechnicians = RadarTechnician.seedTechnicians;
    _selectedTech = _allTechnicians.first;
    _fetchRealUserLocation();
  }

  Future<void> _fetchRealUserLocation() async {
    setState(() => _isLocatingUser = true);
    try {
      final loc = await LocationService.getRealTimeLocation();
      if (mounted) {
        setState(() {
          _userPosition = LatLng(loc.latitude, loc.longitude);
          _isLocatingUser = false;
        });
        _mapController.move(_userPosition, _currentZoom);
      }
    } catch (_) {
      if (mounted) setState(() => _isLocatingUser = false);
    }
  }

  void _recenterToUser() {
    _mapController.move(_userPosition, 14.5);
  }

  void _zoomIn() {
    setState(() => _currentZoom = math.min(_currentZoom + 1.0, 18.0));
    _mapController.move(_mapController.camera.center, _currentZoom);
  }

  void _zoomOut() {
    setState(() => _currentZoom = math.max(_currentZoom - 1.0, 5.0));
    _mapController.move(_mapController.camera.center, _currentZoom);
  }

  List<RadarTechnician> get _filteredTechnicians {
    return _allTechnicians.where((tech) {
      if (_selectedRadiusKm < 10 && tech.distanceKm > _selectedRadiusKm) {
        return false;
      }
      if (_selectedTradeFilter == 'Electrical' &&
          !tech.trade.toLowerCase().contains('electric') &&
          !tech.trade.toLowerCase().contains('wiring')) {
        return false;
      }
      if (_selectedTradeFilter == 'HVAC' &&
          !tech.trade.toLowerCase().contains('ac') &&
          !tech.trade.toLowerCase().contains('hvac')) {
        return false;
      }
      if (_selectedTradeFilter == 'Plumbing' &&
          !tech.trade.toLowerCase().contains('plumb')) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // 1. Sheet Grabber & Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.primarySky.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.map_rounded,
                            color: AppColors.primaryRoyal,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn
                                  ? 'লাইভ গুগল ম্যাপ ও রাডার'
                                  : 'Live Street Map & Radar',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              isBn
                                  ? 'সারা দেশব্যাপী ভেরিফায়েড টেকনিশিয়ান'
                                  : 'Nationwide Verified Technicians • ${widget.locationZone}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textMedium,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Radius & Trade Filter Horizontal Strips
          RadarMapFilterBar(
            selectedRadiusKm: _selectedRadiusKm,
            onRadiusChanged: (km) => setState(() => _selectedRadiusKm = km),
            selectedTradeFilter: _selectedTradeFilter,
            onTradeFilterChanged: (val) =>
                setState(() => _selectedTradeFilter = val),
            isBn: isBn,
          ),

          // 3. Real Interactive Street Map Canvas (OpenStreetMap Tiles)
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _userPosition,
                    initialZoom: _currentZoom,
                    minZoom: 4.0,
                    maxZoom: 18.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    // Real OpenStreetMap Tile Layer (Global & Bangladesh Street View)
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.skavia.app',
                      maxZoom: 19,
                    ),

                    // User Location & Nearby Technician Markers
                    MarkerLayer(
                      markers: [
                        // Live User Location Marker (Pulsing Blue Beacon)
                        Marker(
                          point: _userPosition,
                          width: 52,
                          height: 52,
                          child: GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isBn
                                        ? 'আপনার আসল জিপিএস লোকেশন'
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

                        // Filtered Technician Markers
                        ..._filteredTechnicians.map((tech) {
                          final isSelected = _selectedTech?.id == tech.id;
                          return Marker(
                            point: LatLng(tech.latitude, tech.longitude),
                            width: isSelected ? 56 : 46,
                            height: isSelected ? 56 : 46,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedTech = tech);
                                _mapController.move(
                                  LatLng(tech.latitude, tech.longitude),
                                  14.5,
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryRoyal
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : tech.color,
                                    width: isSelected ? 3 : 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.25,
                                      ),
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

                // Map Floating Controls (Recenter to GPS, Zoom In, Zoom Out)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Column(
                    children: [
                      _buildFloatingControlBtn(
                        icon: _isLocatingUser
                            ? Icons.hourglass_top_rounded
                            : Icons.my_location_rounded,
                        tooltip: 'Recenter to My GPS Location',
                        onTap: _recenterToUser,
                      ),
                      const SizedBox(height: 8),
                      _buildFloatingControlBtn(
                        icon: Icons.add,
                        tooltip: 'Zoom In',
                        onTap: _zoomIn,
                      ),
                      const SizedBox(height: 8),
                      _buildFloatingControlBtn(
                        icon: Icons.remove,
                        tooltip: 'Zoom Out',
                        onTap: _zoomOut,
                      ),
                    ],
                  ),
                ),

                // Floating Status Pill
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                          '${_filteredTechnicians.length} ${isBn ? "কারিগর অনলাইন" : "Pros Online"}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Selected Technician Bottom Preview & Action Card
          if (_selectedTech != null)
            RadarTechnicianCard(
              technician: _selectedTech!,
              onBook: () {
                final tech = _selectedTech!;
                Navigator.pop(context);
                if (widget.onSelectTechnician != null) {
                  widget.onSelectTechnician!(tech);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingControlBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
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
}
