import 'dart:convert';

/// High-performance local cache service supporting TTL expiry and offline read fallbacks.
class LocalCacheService {
  LocalCacheService._internal();
  static final LocalCacheService instance = LocalCacheService._internal();

  final Map<String, _CacheEntry> _memoryStore = {};

  /// Stores data in cache with an optional Time-To-Live (TTL).
  void put(String key, dynamic value, {Duration? ttl}) {
    final expiry = ttl != null ? DateTime.now().add(ttl) : null;
    _memoryStore[key] = _CacheEntry(
      value: value is String ? value : jsonEncode(value),
      expiry: expiry,
    );
  }

  /// Retrieves data if present and not expired.
  dynamic get(String key) {
    final entry = _memoryStore[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _memoryStore.remove(key);
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
      return false;
    }
    return true;
  }

  /// Removes a cached key.
  void remove(String key) {
    _memoryStore.remove(key);
  }

  /// Clears the entire local cache.
  void clear() {
    _memoryStore.clear();
  }

  /// Returns count of valid active cache entries.
  int get count => _memoryStore.values.where((e) => !e.isExpired).length;
}

class _CacheEntry {
  final String value;
  final DateTime? expiry;

  _CacheEntry({required this.value, this.expiry});

  bool get isExpired => expiry != null && DateTime.now().isAfter(expiry!);
}

