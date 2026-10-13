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
  final ValueChanged<String>? onLocationSelected;

  const RadarMapSheet({
    super.key,
    required this.locationZone,
    this.onSelectTechnician,
    this.onLocationSelected,
  });

  static void show(
    BuildContext context, {
    required String locationZone,
    Function(RadarTechnician)? onSelectTechnician,
    ValueChanged<String>? onLocationSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RadarMapSheet(
        locationZone: locationZone,
        onSelectTechnician: onSelectTechnician,
        onLocationSelected: onLocationSelected,
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

  // Custom User Map Tap Pin & Reverse Geocode State
  LatLng? _selectedCustomPoint;
  String? _selectedPointAddress;
  bool _isReverseGeocoding = false;

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
      // Calculate real physical distance from user position
      final realDist = LocationService.calculateDistanceKm(
        _userPosition.latitude,
        _userPosition.longitude,
        tech.latitude,
        tech.longitude,
      );
      if (_selectedRadiusKm < 10 && realDist > _selectedRadiusKm) {
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
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.90,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                      color: colorScheme.outlineVariant,
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
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              isBn
                                  ? 'সারা দেশব্যাপী ভেরিফায়েড টেকনিশিয়ান'
                                  : 'Nationwide Verified Technicians • ${widget.locationZone}',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: colorScheme.onSurfaceVariant,
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
                    onTap: (tapPosition, point) async {
                      setState(() {
                        _selectedCustomPoint = point;
                        _isReverseGeocoding = true;
                      });
                      final geo = await LocationService.reverseGeocode(
                        point.latitude,
                        point.longitude,
                      );
                      if (mounted) {
                        setState(() {
                          _selectedPointAddress = geo['formatted'];
                          _isReverseGeocoding = false;
                        });
                      }
                    },
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
                        // Custom Tapped Location Pin Marker
                        if (_selectedCustomPoint != null)
                          Marker(
                            point: _selectedCustomPoint!,
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
                        context: context,
                        icon: _isLocatingUser
                            ? Icons.hourglass_top_rounded
                            : Icons.my_location_rounded,
                        tooltip: 'Recenter to My GPS Location',
                        onTap: _recenterToUser,
                      ),
                      const SizedBox(height: 8),
                      _buildFloatingControlBtn(
                        context: context,
                        icon: Icons.add,
                        tooltip: 'Zoom In',
                        onTap: _zoomIn,
                      ),
                      const SizedBox(height: 8),
                      _buildFloatingControlBtn(
                        context: context,
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
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant),
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
            ),
          ),

          // 4. Selected Tap Location Action Banner
          if (_selectedCustomPoint != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.canvasBlue,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primarySky.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.pin_drop_rounded,
                    color: AppColors.accentCoral,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isReverseGeocoding
                              ? (isBn ? 'ঠিকানা খোঁজা হচ্ছে...' : 'Resolving street address...')
                              : (_selectedPointAddress ?? 'Selected Coordinates'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${_selectedCustomPoint!.latitude.toStringAsFixed(4)}, ${_selectedCustomPoint!.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRoyal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      final chosenAddress = _selectedPointAddress ??
                          '${_selectedCustomPoint!.latitude}, ${_selectedCustomPoint!.longitude}';
                      LocationService.syncLocationToSupabase(chosenAddress);
                      widget.onLocationSelected?.call(chosenAddress);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isBn
                                ? 'নির্বাচিত এলাকা সংরক্ষিত হয়েছে: $chosenAddress'
                                : 'Location saved: $chosenAddress',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Text(
                      isBn ? 'এই লোকেশন নিন' : 'Set Location',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 5. Selected Technician Bottom Preview & Action Card
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
}
