import 'package:flutter/material.dart';

/// Central reactive theme service for SKAVIA.
/// Supports Auto (System Default), Light Mode, and Dark Mode.
class AppThemeService {
  static final AppThemeService _instance = AppThemeService._internal();
  factory AppThemeService() => _instance;
  AppThemeService._internal();

  /// Reactive notifier holding currently active ThemeMode
  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  static ThemeMode get themeMode => themeModeNotifier.value;

  static bool get isSystem => themeModeNotifier.value == ThemeMode.system;
  static bool get isDark => themeModeNotifier.value == ThemeMode.dark;
  static bool get isLight => themeModeNotifier.value == ThemeMode.light;

  static void setThemeMode(ThemeMode mode) {
    themeModeNotifier.value = mode;
  }

  /// Cycles: System -> Light -> Dark -> System
  static void cycleThemeMode() {
    switch (themeModeNotifier.value) {
      case ThemeMode.system:
        themeModeNotifier.value = ThemeMode.light;
        break;
      case ThemeMode.light:
        themeModeNotifier.value = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        themeModeNotifier.value = ThemeMode.system;
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
