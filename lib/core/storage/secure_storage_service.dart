import 'dart:async';

/// Local session and preference cache for SKAVIA.
class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final Map<String, String> _cache = {};

  Future<void> write({required String key, required String value}) async {
    _cache[key] = value;
  }

  Future<String?> read({required String key}) async {
    return _cache[key];
  }

  Future<void> delete({required String key}) async {
    _cache.remove(key);
  }

  Future<void> clearAll() async {
    _cache.clear();
  }
}
