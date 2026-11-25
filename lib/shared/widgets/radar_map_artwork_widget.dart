import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/services/app_language_service.dart';
import '../../../core/services/location_service.dart';

/// Live interactive-preview street map card powered by real OpenStreetMap / CartoDB
/// Google-style Retina tiles and real device GPS coordinates.
/// Tapping anywhere expands the full interactive [RadarMapSheet].
class RadarMapArtworkWidget extends StatefulWidget {
  final String locationZone;
  final int activeTechCount;
  final VoidCallback? onExpand;

  const RadarMapArtworkWidget({
    super.key,
    required this.locationZone,
    this.activeTechCount = 0,
    this.onExpand,
  });

  @override
  State<RadarMapArtworkWidget> createState() => _RadarMapArtworkWidgetState();
}

class _RadarMapArtworkWidgetState extends State<RadarMapArtworkWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  final MapController _mapController = MapController();
  late LatLng _centerCoords;
  bool _hasGpsLock = false;

  @override
  void initState() {
    super.initState();
    _centerCoords = _resolveZoneCoordinates(widget.locationZone);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _syncLiveGps();
  }

  @override
  void didUpdateWidget(covariant RadarMapArtworkWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locationZone != widget.locationZone && !_hasGpsLock) {
      final updated = _resolveZoneCoordinates(widget.locationZone);
      setState(() => _centerCoords = updated);
      try {
        _mapController.move(updated, 14.5);
      } catch (_) {}
    }
  }

  Future<void> _syncLiveGps() async {
    try {
      final result = await LocationService.getRealTimeLocation();
      if (!mounted) return;
      final livePoint = LatLng(result.latitude, result.longitude);
      setState(() {
        _centerCoords = livePoint;
        _hasGpsLock = result.isFromGps;
      });
      try {
        _mapController.move(livePoint, 14.8);
      } catch (_) {}
    } catch (_) {}
  }

  static LatLng _resolveZoneCoordinates(String zone) {
    final lower = zone.toLowerCase();
    if (lower.contains('gulshan')) return const LatLng(23.7925, 90.4078);
    if (lower.contains('banani')) return const LatLng(23.7937, 90.4066);
    if (lower.contains('uttara')) return const LatLng(23.8759, 90.3795);
    if (lower.contains('mirpur')) return const LatLng(23.8069, 90.3687);
    if (lower.contains('mohakhali')) return const LatLng(23.7778, 90.4057);
    if (lower.contains('bashundhara')) return const LatLng(23.8191, 90.4526);
    if (lower.contains('mohammadpur')) return const LatLng(23.7658, 90.3584);
    if (lower.contains('badda')) return const LatLng(23.7805, 90.4267);
    if (lower.contains('baridhara')) return const LatLng(23.8058, 90.4202);
    if (lower.contains('tejgaon')) return const LatLng(23.7598, 90.3912);
    if (lower.contains('motijheel')) return const LatLng(23.7330, 90.4172);
    if (lower.contains('khilgaon')) return const LatLng(23.7566, 90.4263);
    if (lower.contains('malibagh')) return const LatLng(23.7493, 90.4126);
    if (lower.contains('lalbagh')) return const LatLng(23.7196, 90.3881);
    return const LatLng(23.7461, 90.3742); // Dhanmondi, Dhaka
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isBn = AppLanguageService.isBengali;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final mapHeight = textScale > 1.3 ? 196.0 : 172.0;

    // Crisp CartoDB Voyager (Light) & DarkMatter (Dark) tiles — 100% free, no API key, no 401
    final tileUrl = isDark
        ? 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
        : 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
    final isRetina = RetinaMode.isHighDensity(context);

    return GestureDetector(
      onTap: widget.onExpand,
      child: Container(
        width: double.infinity,
        height: mapHeight,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141B29) : const Color(0xFFE8EEF5),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFD5DFEA),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(21),
          child: Stack(
            children: [
              // 1. Real Street Map Canvas (Non-blocking preview; tap opens full map)
              IgnorePointer(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _centerCoords,
                    initialZoom: 14.5,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: tileUrl,
                      fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      retinaMode: isRetina,
                      userAgentPackageName: 'com.skavia.app',
                      maxZoom: 19,
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _centerCoords,
                          width: 64,
                          height: 64,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, _) {
                              final t = _pulseController.value;
                              final haloSize = 22.0 + (t * 36.0);
                              final haloOpacity = (1.0 - t) * 0.35;
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: haloSize,
                                    height: haloSize,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A73E8)
                                          .withValues(alpha: haloOpacity),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A73E8),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Subtle bottom readability scrim
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 64,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: isDark ? 0.65 : 0.38),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Top-Left Live Location Pill (Google Maps Clean Pill)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A).withValues(alpha: 0.92)
                        : Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _hasGpsLock
                            ? Icons.my_location_rounded
                            : Icons.location_on_rounded,
                        size: 14,
                        color: const Color(0xFF1A73E8),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.locationZone,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Top-Right Live Specialist Badge (only shown if genuine count > 0)
              if (widget.activeTechCount > 0)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.16),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.engineering_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.activeTechCount} ${isBn ? "জন সক্রিয়" : "Online"}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 5. Bottom-Left Title & Bottom-Right "Explore Map" CTA (Responsive, zero overflow)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final textScale = MediaQuery.textScalerOf(context)
                        .scale(1.0);
                    final compact =
                        constraints.maxWidth < 290 || textScale > 1.3;
                    final colorScheme = Theme.of(context).colorScheme;

                    final titleColumn = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isBn ? 'লাইভ সার্ভিস ম্যাপ' : 'Live Service Map',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 6),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!compact) ...[
                          const SizedBox(height: 1),
                          Text(
                            isBn
                                ? 'কাছাকাছি দক্ষ কারিগর খুঁজতে ট্যাপ করুন'
                                : 'Tap to explore nearby pros & streets',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              shadows: const [
                                Shadow(color: Colors.black54, blurRadius: 4),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    );

                    final explorePill = Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              isBn ? 'ম্যাপ' : 'Explore Map',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.open_in_full_rounded,
                            color: colorScheme.onPrimary,
                            size: 13,
                          ),
                        ],
                      ),
                    );

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          titleColumn,
                          const SizedBox(height: 6),
                          explorePill,
                        ],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: titleColumn),
                        const SizedBox(width: 8),
                        Flexible(flex: 0, child: explorePill),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
