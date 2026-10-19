import 'package:flutter/material.dart';

import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/models/user_address_model.dart';
import '../../data/models/user_profile_model.dart';
import '../../domain/services/profile_completion_engine.dart';

class ProfileController extends ChangeNotifier {
  final ProfileRemoteDataSource _dataSource;

  ProfileController({ProfileRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? ProfileRemoteDataSource();

  UserProfileModel? _profile;
  ProfileCompletionResult? _completionResult;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;

  UserProfileModel? get profile => _profile;
  ProfileCompletionResult? get completionResult => _completionResult;
  bool get isLoading => _isLoading;
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

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _dataSource.getProfile(userId);
      _recalculateCompletion();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
    DateTime? dateOfBirth,
    bool? birthdayNotificationsEnabled,
    String? gender,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? preferredLanguage,
    String? timezone,
  }) async {
    if (_profile == null) return false;

    _isLoading = true;
    notifyListeners();

    final updated = _profile!.copyWith(
      fullName: fullName ?? _profile!.fullName,
      phone: phone ?? _profile!.phone,
      avatarUrl: avatarUrl ?? _profile!.avatarUrl,
      dateOfBirth: dateOfBirth ?? _profile!.dateOfBirth,
      birthdayNotificationsEnabled:
          birthdayNotificationsEnabled ?? _profile!.birthdayNotificationsEnabled,
      gender: gender ?? _profile!.gender,
      emergencyContactName:
          emergencyContactName ?? _profile!.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? _profile!.emergencyContactPhone,
      preferredLanguage: preferredLanguage ?? _profile!.preferredLanguage,
      timezone: timezone ?? _profile!.timezone,
    );

    final success = await _dataSource.updateProfile(updated);
    if (success) {
      _profile = updated;
      _recalculateCompletion();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> addOrUpdateAddress(UserAddressModel address) async {
    if (_profile == null) return false;

    final success = await _dataSource.saveAddress(address);
    if (success) {
      final addresses = List<UserAddressModel>.from(_profile!.savedAddresses);
      final index = addresses.indexWhere((a) => a.id == address.id);
      if (index >= 0) {
        addresses[index] = address;
      } else {
        addresses.add(address);
      }
      _profile = _profile!.copyWith(savedAddresses: addresses);
      _recalculateCompletion();
      notifyListeners();
    }
    return success;
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

  void _recalculateCompletion() {
    if (_profile != null) {
      _completionResult = ProfileCompletionEngine.evaluate(_profile!);
      _profile = _profile!.copyWith(
        profileCompletionPercentage: _completionResult!.percentage,
      );
    }
  }
}

