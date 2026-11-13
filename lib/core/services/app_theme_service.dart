import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Central reactive theme service for SKAVIA.
/// Supports Auto (System Default), Light Mode, and Dark Mode with disk persistence.
class AppThemeService {
  static final AppThemeService _instance = AppThemeService._internal();
  factory AppThemeService() => _instance;
  AppThemeService._internal();

  /// Reactive notifier holding currently active ThemeMode.
  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  static SharedPreferences? _prefs;

  static ThemeMode get themeMode => themeModeNotifier.value;

  static bool get isSystem => themeModeNotifier.value == ThemeMode.system;
  static bool get isDark => themeModeNotifier.value == ThemeMode.dark;
  static bool get isLight => themeModeNotifier.value == ThemeMode.light;

  /// Restores persisted theme mode preference on app startup.
  static Future<void> init({SharedPreferences? prefs}) async {
    try {
      _prefs = prefs ?? await SharedPreferences.getInstance();
      final saved = _prefs?.getString(AppConstants.themeStorageKey);
      if (saved != null) {
        themeModeNotifier.value = _parseThemeMode(saved);
      }
    } catch (e) {
      debugPrint('[AppThemeService] Init fallback: $e');
    }
  }

  static ThemeMode _parseThemeMode(String raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> _persist(ThemeMode mode) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      _prefs = prefs;
      await prefs.setString(AppConstants.themeStorageKey, mode.name);
    } catch (_) {}
  }

  static void setThemeMode(ThemeMode mode) {
    themeModeNotifier.value = mode;
    _persist(mode);
  }

  /// Cycles: System -> Light -> Dark -> System
  static void cycleThemeMode() {
    switch (themeModeNotifier.value) {
      case ThemeMode.system:
        setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setThemeMode(ThemeMode.system);
        break;
    }
  }

  /// User-friendly label
  static String getThemeLabel({required bool isBengali}) {
    switch (themeModeNotifier.value) {
      case ThemeMode.system:
        return isBengali ? 'সিস্টেম অটো (স্বয়ংক্রিয়)' : 'System Auto';
      case ThemeMode.light:
        return isBengali ? 'লাইট মোড (উজ্জ্বল)' : 'Light Mode';
      case ThemeMode.dark:
        return isBengali ? 'ডার্ক মোড (অন্ধকার)' : 'Dark Mode';
    }
  }
}
