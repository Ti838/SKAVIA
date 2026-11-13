import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent audio chime, message tone, vibration, and haptic feedback preferences.
class SoundHapticPreferences extends ChangeNotifier {
  SoundHapticPreferences._internal();
  static final SoundHapticPreferences instance =
      SoundHapticPreferences._internal();

  static const String _kNotifSound = 'skavia_pref_notif_sound';
  static const String _kMessageSound = 'skavia_pref_msg_sound';
  static const String _kVibration = 'skavia_pref_vibration';
  static const String _kHaptics = 'skavia_pref_haptics';
  static const String _kTimezone = 'skavia_pref_timezone';
  static const String _kDateFormat = 'skavia_pref_date_format';

  SharedPreferences? _prefs;
  bool notificationSoundEnabled = true;
  bool messageSoundEnabled = true;
  bool vibrationEnabled = true;
  bool hapticFeedbackEnabled = true;
  String timezone = 'Asia/Dhaka (BST, UTC+6)';
  String dateFormat = 'DD MMM YYYY';

  Future<void> init({SharedPreferences? prefs}) async {
    try {
      _prefs = prefs ?? await SharedPreferences.getInstance();
      notificationSoundEnabled = _prefs?.getBool(_kNotifSound) ?? true;
      messageSoundEnabled = _prefs?.getBool(_kMessageSound) ?? true;
      vibrationEnabled = _prefs?.getBool(_kVibration) ?? true;
      hapticFeedbackEnabled = _prefs?.getBool(_kHaptics) ?? true;
      timezone = _prefs?.getString(_kTimezone) ?? timezone;
      dateFormat = _prefs?.getString(_kDateFormat) ?? dateFormat;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setNotificationSound(bool value) async {
    notificationSoundEnabled = value;
    notifyListeners();
    try {
      final p = _prefs ?? await SharedPreferences.getInstance();
      _prefs = p;
      await p.setBool(_kNotifSound, value);
    } catch (_) {}
  }

  Future<void> setMessageSound(bool value) async {
    messageSoundEnabled = value;
    notifyListeners();
    try {
      final p = _prefs ?? await SharedPreferences.getInstance();
      _prefs = p;
      await p.setBool(_kMessageSound, value);
    } catch (_) {}
  }

  Future<void> setVibrationEnabled(bool value) async {
    vibrationEnabled = value;
    notifyListeners();
    try {
      final p = _prefs ?? await SharedPreferences.getInstance();
      _prefs = p;
      await p.setBool(_kVibration, value);
    } catch (_) {}
  }

  Future<void> setHapticFeedback(bool value) async {
    hapticFeedbackEnabled = value;
    notifyListeners();
    try {
      final p = _prefs ?? await SharedPreferences.getInstance();
      _prefs = p;
      await p.setBool(_kHaptics, value);
    } catch (_) {}
  }

  Future<void> setRegionPreferences({
    String? newTimezone,
    String? newDateFormat,
  }) async {
    if (newTimezone != null) timezone = newTimezone;
    if (newDateFormat != null) dateFormat = newDateFormat;
    notifyListeners();
    try {
      final p = _prefs ?? await SharedPreferences.getInstance();
      _prefs = p;
      await p.setString(_kTimezone, timezone);
      await p.setString(_kDateFormat, dateFormat);
    } catch (_) {}
  }
}

