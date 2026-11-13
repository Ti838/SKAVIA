import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent local cache service supporting TTL expiry and offline read fallbacks.
/// Maintains synchronous read/write semantics via an in-memory mirror backed by
/// [SharedPreferences] when platform storage is available.
class LocalCacheService {
  LocalCacheService._internal();
  static final LocalCacheService instance = LocalCacheService._internal();

  static const String _diskStorageKey = 'skavia_local_cache_store_v1';
  final Map<String, _CacheEntry> _memoryStore = {};
  SharedPreferences? _prefs;
  bool _initialized = false;

  /// Hydrates non-expired entries from persistent disk storage on startup.
  Future<void> init({SharedPreferences? prefs}) async {
    if (_initialized && prefs == null) return;
    try {
      _prefs = prefs ?? await SharedPreferences.getInstance();
      final raw = _prefs?.getString(_diskStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          final now = DateTime.now();
          decoded.forEach((key, entryRaw) {
            if (entryRaw is Map<String, dynamic>) {
              final value = entryRaw['value']?.toString();
              final expiryIso = entryRaw['expiry']?.toString();
              final expiry =
                  expiryIso != null ? DateTime.tryParse(expiryIso) : null;
              if (value != null && (expiry == null || !now.isAfter(expiry))) {
                _memoryStore[key] = _CacheEntry(value: value, expiry: expiry);
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint('[LocalCacheService] Disk init fallback (memory-only): $e');
    } finally {
      _initialized = true;
    }
  }

  /// Stores data in cache with an optional Time-To-Live (TTL).
  void put(String key, dynamic value, {Duration? ttl}) {
    final expiry = ttl != null ? DateTime.now().add(ttl) : null;
    _memoryStore[key] = _CacheEntry(
      value: value is String ? value : jsonEncode(value),
      expiry: expiry,
    );
    _persistAsync();
  }

  /// Retrieves data if present and not expired.
  dynamic get(String key) {
    final entry = _memoryStore[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _memoryStore.remove(key);
      _persistAsync();
      return null;
    }

    try {
      return jsonDecode(entry.value);
    } catch (_) {
      return entry.value;
    }
  }

  /// Checks if key exists and is valid.
  bool has(String key) {
    final entry = _memoryStore[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _memoryStore.remove(key);
      _persistAsync();
      return false;
    }
    return true;
  }

  /// Removes a cached key.
  void remove(String key) {
    _memoryStore.remove(key);
    _persistAsync();
  }

  /// Clears the entire local cache.
  void clear() {
    _memoryStore.clear();
    _persistAsync();
  }

  /// Returns count of valid active cache entries.
  int get count => _memoryStore.values.where((e) => !e.isExpired).length;

  void _persistAsync() {
    final prefs = _prefs;
    if (prefs == null) return;
    try {
      final serialized = <String, Map<String, dynamic>>{};
      _memoryStore.forEach((key, entry) {
        if (!entry.isExpired) {
          serialized[key] = {
            'value': entry.value,
            if (entry.expiry != null)
              'expiry': entry.expiry!.toIso8601String(),
          };
        }
      });
      prefs.setString(_diskStorageKey, jsonEncode(serialized));
    } catch (e) {
      debugPrint('[LocalCacheService] Disk write notice: $e');
    }
  }
}

class _CacheEntry {
  final String value;
  final DateTime? expiry;

  _CacheEntry({required this.value, this.expiry});

  bool get isExpired => expiry != null && DateTime.now().isAfter(expiry!);
}
