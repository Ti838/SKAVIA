import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationResult {
  final String formattedAddress;
  final String zone;
  final double latitude;
  final double longitude;
  final bool isFromGps;

  const LocationResult({
    required this.formattedAddress,
    required this.zone,
    required this.latitude,
    required this.longitude,
    required this.isFromGps,
  });
}

class LocationService {
  static const List<String> dhakaZones = [
    'Dhanmondi',
    'Gulshan',
    'Banani',
    'Uttara',
    'Mirpur',
    'Mohakhali',
    'Bashundhara R/A',
    'Mohammadpur',
    'Badda',
    'Baridhara',
    'Tejgaon',
    'Motijheel',
    'Khilgaon',
    'Malibagh',
    'Lalbagh',
  ];

  /// Detects real-time device location using GPS sensors with reverse geocoding
  static Future<LocationResult> getRealTimeLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return await _fallbackIpLocation();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return await _fallbackIpLocation();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return await _fallbackIpLocation();
      }

      // Obtain high accuracy position from hardware GPS
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      // Reverse geocode coordinates to get actual Dhaka Thana/Neighborhood
      final addressData = await _reverseGeocode(
        position.latitude,
        position.longitude,
      );

      final result = LocationResult(
        formattedAddress: addressData['formatted'] ?? 'Dhaka, Bangladesh',
        zone: addressData['zone'] ?? 'Dhaka',
        latitude: position.latitude,
        longitude: position.longitude,
        isFromGps: true,
      );

      // Sync real location to Supabase user profile
      await syncLocationToSupabase(result.formattedAddress);

      return result;
    } catch (e) {
      debugPrint('[LocationService] GPS error, falling back to IP: $e');
      return await _fallbackIpLocation();
    }
  }

  /// Calculates Haversine distance in kilometers between two GPS coordinate pairs
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double p = 0.017453292519943295; // Math.PI / 180
    final double a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R * asin...
  }

  /// Forward geocode address query to real GPS coordinates using OpenStreetMap Nominatim
  static Future<Map<String, double>?> geocodeAddress(String query) async {
    try {
      final encoded = Uri.encodeComponent('$query, Bangladesh');
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$encoded&format=json&limit=1',
      );
      final response = await http
          .get(
            url,
            headers: {
              'User-Agent': 'SKAVIA_Mobile_App/1.0 (contact@skavia.com)',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        if (list.isNotEmpty) {
          final first = list.first as Map<String, dynamic>;
          final lat = double.tryParse(first['lat']?.toString() ?? '');
          final lon = double.tryParse(first['lon']?.toString() ?? '');
          if (lat != null && lon != null) {
            return {'latitude': lat, 'longitude': lon};
          }
        }
      }
    } catch (e) {
      debugPrint('[LocationService] Forward geocode error: $e');
    }
    return null;
  }

  /// Reverse geocodes lat/lng into human-readable Dhaka address using OpenStreetMap
  static Future<Map<String, String>> reverseGeocode(
    double lat,
    double lon,
  ) async {
    return _reverseGeocode(lat, lon);
  }

  static Future<Map<String, String>> _reverseGeocode(
    double lat,
    double lon,
  ) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&addressdetails=1',
      );
      final response = await http
          .get(
            url,
            headers: {
              'User-Agent': 'SKAVIA_Mobile_App/1.0 (contact@skavia.com)',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>? ?? {};

        final suburb =
            address['suburb'] ??
            address['neighbourhood'] ??
            address['residential'] ??
            address['quarter'] ??
            address['city_district'];

        final matchedZone = _matchDhakaZone(
          suburb?.toString() ?? data['display_name']?.toString() ?? '',
        );

        final formatted = suburb != null
            ? '$suburb, Dhaka'
            : (matchedZone.isNotEmpty
                  ? '$matchedZone, Dhaka'
                  : 'Dhaka, Bangladesh');

        return {
          'zone': matchedZone.isNotEmpty ? matchedZone : 'Dhaka',
          'formatted': formatted,
        };
      }
    } catch (e) {
      debugPrint('[LocationService] Reverse geocode error: $e');
    }

    return {'zone': 'Dhaka', 'formatted': 'Dhaka, Bangladesh'};
  }

  /// Fallback using network IP location if GPS is disabled or denied
  static Future<LocationResult> _fallbackIpLocation() async {
    try {
      final res = await http
          .get(Uri.parse('http://ip-api.com/json'))
          .timeout(const Duration(seconds: 3));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final city = data['city'] ?? 'Dhaka';
        final lat = (data['lat'] as num?)?.toDouble() ?? 23.8103;
        final lon = (data['lon'] as num?)?.toDouble() ?? 90.4125;

        final matchedZone = _matchDhakaZone(city.toString());

        return LocationResult(
          formattedAddress: '$city, Bangladesh',
          zone: matchedZone.isNotEmpty ? matchedZone : 'Dhanmondi',
          latitude: lat,
          longitude: lon,
          isFromGps: false,
        );
      }
    } catch (_) {}

    return const LocationResult(
      formattedAddress: 'Dhanmondi, Dhaka',
      zone: 'Dhanmondi',
      latitude: 23.7465,
      longitude: 90.3760,
      isFromGps: false,
    );
  }

  /// Maps raw locality strings to canonical SKAVIA Dhaka operating zones
  static String _matchDhakaZone(String text) {
    final lower = text.toLowerCase();
    for (final zone in dhakaZones) {
      if (lower.contains(zone.toLowerCase())) {
        return zone;
      }
    }
    return '';
  }

  /// Updates current user profile location in Supabase
  static Future<void> syncLocationToSupabase(String locationString) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('users')
            .update({'location': locationString})
            .eq('user_id', user.id);
      }
    } catch (e) {
      debugPrint('[LocationService] Supabase sync error: $e');
    }
  }
}
