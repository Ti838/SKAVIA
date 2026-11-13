import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';

import '../../../../core/services/app_language_service.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/models/profile_stats_model.dart';
import '../../data/models/user_address_model.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/models/user_session_model.dart';
import '../../domain/services/profile_completion_engine.dart';

class ProfileController extends ChangeNotifier {
  static final ProfileController shared = ProfileController();

  final ProfileRemoteDataSource _dataSource;

  ProfileController({ProfileRemoteDataSource? dataSource})
    : _dataSource = dataSource ?? ProfileRemoteDataSource();

  UserProfileModel? _profile;
  ProfileCompletionResult? _completionResult;
  ProfileStatsModel _stats = const ProfileStatsModel();
  List<UserSessionModel> _sessions = const [];
  String _currentDeviceId = '';
  bool _isLoading = false;
  bool _isSessionsLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;

  UserProfileModel? get profile => _profile;
  ProfileCompletionResult? get completionResult => _completionResult;
  ProfileStatsModel get stats => _stats;
  List<UserSessionModel> get sessions => List.unmodifiable(_sessions);
  String get currentDeviceId => _currentDeviceId;
  bool get isLoading => _isLoading;
  bool get isSessionsLoading => _isSessionsLoading;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  fb.User? _tryCurrentFirebaseUser() {
    try {
      return fb.FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  Future<void> loadProfile(
    String userId, {
    String? fallbackEmail,
    String? fallbackName,
    String? fallbackPhone,
    String? fallbackAvatarUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _dataSource.getProfile(
        userId,
        fallbackEmail: fallbackEmail,
        fallbackName: fallbackName,
        fallbackPhone: fallbackPhone,
        fallbackAvatarUrl: fallbackAvatarUrl,
      );
      _recalculateCompletion();
      _stats = await _dataSource.getProfileStats(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Hydrates profile & stats for the currently signed-in user if not already loaded.
  Future<void> loadCurrentUserIfNeeded({
    String? userId,
    String? fallbackEmail,
    String? fallbackName,
    String? fallbackPhone,
    String? fallbackAvatarUrl,
  }) async {
    final fbUser = _tryCurrentFirebaseUser();
    final resolvedId = userId ?? fbUser?.uid;
    if (resolvedId == null || resolvedId.isEmpty) {
      if (_profile == null) {
        _profile = UserProfileModel(
          id: 'guest',
          email: fallbackEmail ?? '',
          fullName: fallbackName ?? 'SKAVIA Member',
          phone: fallbackPhone,
          avatarUrl: fallbackAvatarUrl,
        );
        _recalculateCompletion();
        notifyListeners();
      }
      return;
    }
    if (_profile == null || _profile!.id != resolvedId || _profile!.id == 'guest') {
      await loadProfile(
        resolvedId,
        fallbackEmail: fallbackEmail ?? fbUser?.email,
        fallbackName: fallbackName ?? fbUser?.displayName,
        fallbackPhone: fallbackPhone ?? fbUser?.phoneNumber,
        fallbackAvatarUrl: fallbackAvatarUrl ?? fbUser?.photoURL,
      );
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? coverUrl,
    String? customerType,
    String? companyName,
    String? tradeLicense,
    String? billingAddress,
    DateTime? dateOfBirth,
    bool? birthdayNotificationsEnabled,
    String? gender,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? preferredLanguage,
    String? timezone,
    Map<String, dynamic>? privacySettings,
    Map<String, dynamic>? notificationPreferences,
  }) async {
    if (_profile == null) return false;

    _isLoading = true;
    notifyListeners();

    final updatedPrivacy = Map<String, dynamic>.from(
      privacySettings ?? _profile!.privacySettings,
    );
    if (coverUrl != null) {
      if (coverUrl.trim().isEmpty) {
        updatedPrivacy.remove('cover_url');
      } else {
        updatedPrivacy['cover_url'] = coverUrl.trim();
      }
    }

    final updated = _profile!.copyWith(
      fullName: fullName ?? _profile!.fullName,
      phone: phone ?? _profile!.phone,
      avatarUrl: avatarUrl ?? _profile!.avatarUrl,
      coverUrl: coverUrl ?? _profile!.coverUrl,
      customerType: customerType ?? _profile!.customerType,
      companyName: companyName ?? _profile!.companyName,
      tradeLicense: tradeLicense ?? _profile!.tradeLicense,
      billingAddress: billingAddress ?? _profile!.billingAddress,
      dateOfBirth: dateOfBirth ?? _profile!.dateOfBirth,
      birthdayNotificationsEnabled:
          birthdayNotificationsEnabled ??
          _profile!.birthdayNotificationsEnabled,
      gender: gender ?? _profile!.gender,
      emergencyContactName:
          emergencyContactName ?? _profile!.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? _profile!.emergencyContactPhone,
      preferredLanguage: preferredLanguage ?? _profile!.preferredLanguage,
      timezone: timezone ?? _profile!.timezone,
      privacySettings: updatedPrivacy,
      notificationPreferences:
          notificationPreferences ?? _profile!.notificationPreferences,
    );

    if (preferredLanguage != null &&
        (preferredLanguage == 'en' || preferredLanguage == 'bn')) {
      AppLanguageService.setLanguage(preferredLanguage);
    }

    final success = await _dataSource.updateProfile(updated);
    if (success) {
      _profile = updated;
      _recalculateCompletion();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> updatePrivacySettings(Map<String, dynamic> nextPrivacy) async {
    return updateProfile(privacySettings: nextPrivacy);
  }

  Future<bool> addOrUpdateAddress(UserAddressModel address) async {
    if (_profile == null) return false;

    final resolvedAddress = address.userId.isEmpty
        ? address.copyWith(userId: _profile!.id)
        : address;

    final success = await _dataSource.saveAddress(resolvedAddress);
    if (success) {
      var addresses = List<UserAddressModel>.from(_profile!.savedAddresses);
      if (resolvedAddress.isDefault) {
        addresses = addresses
            .map((a) => a.copyWith(isDefault: a.id == resolvedAddress.id))
            .toList();
      }
      final index = addresses.indexWhere((a) => a.id == resolvedAddress.id);
      if (index >= 0) {
        addresses[index] = resolvedAddress;
      } else {
        addresses.add(resolvedAddress);
      }
      _profile = _profile!.copyWith(savedAddresses: addresses);
      _recalculateCompletion();
      notifyListeners();
    }
    return success;
  }

  Future<bool> setDefaultAddress(UserAddressModel address) async {
    return addOrUpdateAddress(address.copyWith(isDefault: true));
  }

  Future<bool> deleteAddress(String addressId) async {
    if (_profile == null) return false;

    final success = await _dataSource.deleteAddress(addressId, _profile!.id);
    if (success) {
      final addresses = List<UserAddressModel>.from(_profile!.savedAddresses)
        ..removeWhere((a) => a.id == addressId);
      _profile = _profile!.copyWith(savedAddresses: addresses);
      _recalculateCompletion();
      notifyListeners();
    }
    return success;
  }

  Future<void> toggleNotificationPreference(String key, bool value) async {
    if (_profile == null) return;
    final prefs = Map<String, dynamic>.from(_profile!.notificationPreferences);
    prefs[key] = value;
    final updated = _profile!.copyWith(notificationPreferences: prefs);
    await _dataSource.updateProfile(updated);
    _profile = updated;
    notifyListeners();
  }

  Future<void> loadSessions() async {
    final userId = _profile?.id ?? _tryCurrentFirebaseUser()?.uid ?? 'guest';
    _isSessionsLoading = true;
    notifyListeners();
    try {
      _currentDeviceId = await _dataSource.getOrCreateDeviceId();
      _sessions = await _dataSource.getUserSessions(userId);
    } catch (_) {}
    _isSessionsLoading = false;
    notifyListeners();
  }

  Future<bool> revokeSession(String sessionId) async {
    final userId = _profile?.id ?? _tryCurrentFirebaseUser()?.uid ?? 'guest';
    final ok = await _dataSource.revokeSession(sessionId, userId);
    if (ok) {
      _sessions = _sessions
          .map(
            (s) => s.id == sessionId ? s.copyWith(isRevoked: true) : s,
          )
          .toList();
      notifyListeners();
    }
    return ok;
  }

  Future<bool> revokeAllOtherSessions() async {
    final userId = _profile?.id ?? _tryCurrentFirebaseUser()?.uid ?? 'guest';
    final currentId = _currentDeviceId.isEmpty
        ? await _dataSource.getOrCreateDeviceId()
        : _currentDeviceId;
    final ok = await _dataSource.revokeOtherSessions(userId, currentId);
    if (ok) {
      _sessions = _sessions
          .map(
            (s) => s.deviceId == currentId ? s : s.copyWith(isRevoked: true),
          )
          .toList();
      notifyListeners();
    }
    return ok;
  }

  Future<bool> deactivateAccount(String reason) async {
    if (_profile == null) return false;
    _isLoading = true;
    notifyListeners();
    final ok = await _dataSource.deactivateAccount(_profile!.id, reason);
    if (ok) {
      _profile = _profile!.copyWith(accountStatus: 'deactivated');
    }
    _isLoading = false;
    notifyListeners();
    return ok;
  }

  Future<bool> requestAccountDeletion(String reason) async {
    if (_profile == null) return false;
    _isLoading = true;
    notifyListeners();

    final success =
        await _dataSource.requestAccountDeletion(_profile!.id, reason);
    if (success) {
      _profile = _profile!.copyWith(accountStatus: 'pending_deletion');
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }

  void clearSession() {
    _profile = null;
    _completionResult = null;
    _stats = const ProfileStatsModel();
    _sessions = const [];
    _errorMessage = null;
    notifyListeners();
  }

  void _recalculateCompletion() {
    if (_profile != null) {
      _completionResult = ProfileCompletionEngine.evaluate(_profile!);
      _profile = _profile!.copyWith(
        profileCompletionPercentage: _completionResult!.percentage,
      );
    }
  }
}
