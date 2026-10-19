import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/services/app_language_service.dart';
import '../../../core/services/location_service.dart';
import '../models/radar_technician.dart';
import 'radar_location_banner.dart';
import 'radar_map_canvas.dart';
import 'radar_map_filter_bar.dart';
import 'radar_map_header.dart';
import 'radar_technician_card.dart';

export '../models/radar_technician.dart';
export 'radar_location_banner.dart';
export 'radar_map_canvas.dart';
export 'radar_map_controls.dart';
export 'radar_map_filter_bar.dart';
export 'radar_map_header.dart';
export 'radar_technician_card.dart';

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

  List<RadarTechnician> _allTechnicians = List<RadarTechnician>.from(
    RadarTechnician.seedTechnicians,
  );

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedTech = _allTechnicians.first;
    _fetchRealUserLocation();
    _fetchRemoteTechnicians();
  }

  Future<void> _fetchRemoteTechnicians() async {
    try {
      final res = await Supabase.instance.client
          .from('worker_profiles')
          .select(
            'worker_profile_id, title, expected_rate, rating_average, completed_jobs, location, users(full_name)',
          )
          .eq('is_available', true)
          .limit(20);

      if (res.isNotEmpty && mounted) {
        final List<RadarTechnician> remote = [];
        for (final row in res) {
          final id = row['worker_profile_id']?.toString() ?? '';
          final title = row['title']?.toString() ?? 'Specialist';
          final userMap = row['users'] as Map<String, dynamic>?;
          final name =
              userMap?['full_name']?.toString() ?? 'Verified Specialist';
          final rate = (row['expected_rate'] as num?)?.toDouble() ?? 500.0;
          final rating = (row['rating_average'] as num?)?.toDouble() ?? 5.0;
          final jobs = (row['completed_jobs'] as num?)?.toInt() ?? 0;
          final loc = row['location']?.toString() ?? 'Dhaka';

          final double lat =
              23.7461 +
              (remote.length * 0.012 * (remote.length.isEven ? 1 : -1));
          final double lng =
              90.3742 +
              (remote.length * 0.015 * (remote.length.isOdd ? 1 : -1));

          IconData icon = Icons.build_rounded;
          Color color = AppColors.primarySky;
          if (title.toLowerCase().contains('electr')) {
            icon = Icons.electric_bolt_rounded;
            color = AppColors.accentPeach;
          } else if (title.toLowerCase().contains('ac') ||
              title.toLowerCase().contains('hvac')) {
            icon = Icons.ac_unit_rounded;
            color = AppColors.primarySky;
          } else if (title.toLowerCase().contains('plumb')) {
            icon = Icons.plumbing_rounded;
            color = AppColors.accentAqua;
          }

          remote.add(
            RadarTechnician(
              id: id,
              name: name,
              trade: title,
              icon: icon,
              color: color,
              rating: rating,
              jobs: jobs,
              distanceKm: 1.5 + (remote.length * 0.4),
              startingRate: rate,
              latitude: lat,
              longitude: lng,
              zone: loc,
            ),
          );
        }

        if (remote.isNotEmpty) {
          setState(() {
            _allTechnicians = remote;
            _selectedTech = remote.first;
          });
        }
      }
    } catch (e) {
      debugPrint('[RadarMapSheet Remote Tech Notice]: $e');
    }
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
          RadarMapHeader(
            locationZone: widget.locationZone,
            onClose: () => Navigator.pop(context),
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
            child: RadarMapCanvas(
              mapController: _mapController,
              userPosition: _userPosition,
              currentZoom: _currentZoom,
              selectedCustomPoint: _selectedCustomPoint,
              filteredTechnicians: _filteredTechnicians,
              selectedTech: _selectedTech,
              locationZone: widget.locationZone,
              isBn: isBn,
              isLocatingUser: _isLocatingUser,
              onMapTap: (tapPosition, point) async {
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
              onTechnicianTap: (tech) {
                setState(() => _selectedTech = tech);
                _mapController.move(
                  LatLng(tech.latitude, tech.longitude),
                  14.5,
                );
              },
              onRecenter: _recenterToUser,
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
            ),
          ),

          // 4. Selected Tap Location Action Banner
          if (_selectedCustomPoint != null)
            RadarLocationBanner(
              selectedPoint: _selectedCustomPoint!,
              selectedAddress: _selectedPointAddress,
              isReverseGeocoding: _isReverseGeocoding,
              onLocationSelected: widget.onLocationSelected,
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
}
