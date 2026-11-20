import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/services/app_language_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/supabase_guard.dart';
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

  List<RadarTechnician> _allTechnicians = [];
  bool _isLoadingTechnicians = false;
  bool _hasTechnicianError = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedTech = null;
    _fetchRealUserLocation();
    _fetchRemoteTechnicians();
  }

  Future<void> _fetchRemoteTechnicians() async {
    final client = tryGetSupabaseClient();
    if (client == null) return;
    if (mounted) {
      setState(() {
        _isLoadingTechnicians = true;
        _hasTechnicianError = false;
      });
    }
    try {
      final res = await client
          .from('marketplace_public_profiles')
          .select(
            'worker_profile_id, display_name, title, expected_rate, rating_average, completed_jobs, location, verification_status',
          )
          .eq('is_available', true)
          .limit(20);

      if (mounted) {
        final List<RadarTechnician> remote = [];
        for (final row in res) {
          final id = row['worker_profile_id']?.toString() ?? '';
          final title = row['title']?.toString() ?? 'Specialist';
          final name = row['display_name']?.toString() ?? 'Specialist';
          final rate = (row['expected_rate'] as num?)?.toDouble() ?? 0.0;
          final rating = (row['rating_average'] as num?)?.toDouble() ?? 0.0;
          final jobs = (row['completed_jobs'] as num?)?.toInt() ?? 0;
          final loc = row['location']?.toString() ?? 'Dhaka';
          final isVerified =
              row['verification_status']?.toString().toLowerCase() ==
              'verified';

          // Map text zone to canonical Dhaka operating coordinates cleanly
          final anchor = _resolveDhakaZoneCoords(loc);
          final realDist = LocationService.calculateDistanceKm(
            _userPosition.latitude,
            _userPosition.longitude,
            anchor.latitude,
            anchor.longitude,
          );

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
              distanceKm: realDist,
              startingRate: rate,
              latitude: anchor.latitude,
              longitude: anchor.longitude,
              zone: loc,
              isVerified: isVerified,
            ),
          );
        }

        setState(() {
          _allTechnicians = remote;
          _selectedTech = remote.isNotEmpty ? remote.first : null;
          _isLoadingTechnicians = false;
        });
      }
    } catch (e) {
      debugPrint('[RadarMapSheet Remote Tech Notice]: $e');
      if (mounted) {
        setState(() {
          _isLoadingTechnicians = false;
          _hasTechnicianError = true;
        });
      }
    }
  }

  static const LatLng _dhakaCenter = LatLng(23.7808, 90.4071);

  static const Map<String, LatLng> _dhakaZoneCoordinates = {
    'dhanmondi': LatLng(23.7465, 90.3760),
    'gulshan': LatLng(23.7925, 90.4078),
    'banani': LatLng(23.7937, 90.4043),
    'mirpur': LatLng(23.8071, 90.3686),
    'uttara': LatLng(23.8759, 90.3795),
    'mohakhali': LatLng(23.7782, 90.4050),
    'bashundhara': LatLng(23.8191, 90.4526),
    'mohammadpur': LatLng(23.7658, 90.3586),
    'badda': LatLng(23.7806, 90.4267),
    'baridhara': LatLng(23.8012, 90.4222),
    'tejgaon': LatLng(23.7598, 90.3929),
    'motijheel': LatLng(23.7330, 90.4172),
    'khilgaon': LatLng(23.7567, 90.4316),
    'malibagh': LatLng(23.7509, 90.4150),
    'lalbagh': LatLng(23.7196, 90.3881),
  };

  LatLng _resolveDhakaZoneCoords(String locationText) {
    final lower = locationText.toLowerCase();
    for (final entry in _dhakaZoneCoordinates.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return _dhakaCenter;
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
    setState(() => _currentZoom = 14.5);
    _mapController.move(_userPosition, _currentZoom);
  }

  void _zoomIn() {
    setState(() => _currentZoom = math.min(_currentZoom + 1.0, 18.0));
    _mapController.move(_mapController.camera.center, _currentZoom);
  }

  void _zoomOut() {
    setState(() => _currentZoom = math.max(_currentZoom - 1.0, 4.0));
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
                setState(() {
                  _selectedTech = tech;
                  _currentZoom = 14.5;
                });
                _mapController.move(
                  LatLng(tech.latitude, tech.longitude),
                  _currentZoom,
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

          // 5. Selected Technician Bottom Preview & Action Card (or honest status strip)
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
            )
          else if (_selectedCustomPoint == null)
            SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: Row(
                  children: [
                    if (_isLoadingTechnicians) ...[
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isBn
                              ? 'কাছাকাছি কারিগর খোঁজা হচ্ছে...'
                              : 'Searching for available specialists nearby...',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ] else if (_hasTechnicianError) ...[
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 18,
                        color: colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isBn
                              ? 'কারিগরদের তথ্য লোড করা যায়নি।'
                              : 'Could not load nearby specialists.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      TextButton(
                        onPressed: _fetchRemoteTechnicians,
                        child: Text(isBn ? 'আবার চেষ্টা' : 'Retry'),
                      ),
                    ] else ...[
                      Icon(
                        Icons.location_searching_rounded,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isBn
                              ? 'এই এলাকায় এখনও কোনো সক্রিয় কারিগর নেই। ম্যাপে ট্যাপ করে আপনার অবস্থান নির্বাচন করুন।'
                              : 'No active specialists in this area yet. Tap the map to pin your location.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
