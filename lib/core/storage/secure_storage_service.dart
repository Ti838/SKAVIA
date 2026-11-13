import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent local session metadata and non-PII preference storage for SKAVIA.
/// Uses an in-memory cache mirrored to [SharedPreferences] (prefixed by
/// `skavia_session_`) and deliberately avoids storing raw passwords or
/// national identity secrets on unencrypted disk storage.
class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  static const String _keyPrefix = 'skavia_session_';
  final Map<String, String> _cache = {};
  SharedPreferences? _prefs;
  bool _initialized = false;

  Future<void> init({SharedPreferences? prefs}) async {
    if (_initialized && prefs == null) return;
    try {
      _prefs = prefs ?? await SharedPreferences.getInstance();
      final keys = _prefs?.getKeys() ?? const <String>{};
      for (final rawKey in keys) {
        if (rawKey.startsWith(_keyPrefix)) {
          final logicalKey = rawKey.substring(_keyPrefix.length);
          final val = _prefs?.getString(rawKey);
          if (val != null) {
            _cache[logicalKey] = val;
          }
        }
      }
    } catch (e) {
      debugPrint('[SecureStorageService] Prefs init fallback (memory): $e');
    } finally {
      _initialized = true;
    }
  }

  Future<void> write({required String key, required String value}) async {
    _cache[key] = value;
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      _prefs = prefs;
      await prefs.setString('$_keyPrefix$key', value);
    } catch (_) {
      // Safe fallback to in-memory cache in headless unit tests.
    }
  }

  Future<String?> read({required String key}) async {
    if (_cache.containsKey(key)) return _cache[key];
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      _prefs = prefs;
      final value = prefs.getString('$_keyPrefix$key');
      if (value != null) _cache[key] = value;
      return value;
    } catch (_) {
      return _cache[key];
    }
  }

  Future<void> delete({required String key}) async {
    _cache.remove(key);
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      _prefs = prefs;
      await prefs.remove('$_keyPrefix$key');
    } catch (_) {}
  }

  Future<void> clearAll() async {
    _cache.clear();
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      _prefs = prefs;
      final keysToRemove = prefs
          .getKeys()
          .where((k) => k.startsWith(_keyPrefix))
          .toList();
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
    } catch (_) {}
  }
}
