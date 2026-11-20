import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/dialogs/confirmation_dialog.dart';
import '../../../../shared/loaders/list_shimmer_skeleton.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/models/user_profile_model.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_avatar_picker_card.dart';
import '../widgets/profile_corporate_details_section.dart';
import '../widgets/profile_personal_details_section.dart';
import '../widgets/profile_preferences_section.dart';

class EditDetailedProfileScreen extends StatefulWidget {
  final ProfileController controller;

  const EditDetailedProfileScreen({super.key, required this.controller});

  @override
  State<EditDetailedProfileScreen> createState() =>
      _EditDetailedProfileScreenState();
}

class _EditDetailedProfileScreenState extends State<EditDetailedProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyPhoneController;
  late final TextEditingController _companyNameController;
  late final TextEditingController _tradeLicenseController;
  late final TextEditingController _billingAddressController;

  DateTime? _selectedDob;
  bool _birthdayAlertsEnabled = true;
  String _selectedGender = 'prefer_not_to_say';
  String _selectedLanguage = 'en';
  String _selectedTimezone = 'Asia/Dhaka';
  String _customerType = 'Individual';
  String? _avatarUrl;
  String? _coverUrl;
  String? _hydratedProfileId;
  bool _hasUnsavedChanges = false;
  bool _allowPop = false;

  static const List<Map<String, String>> _genderOptions = [
    {'id': 'male', 'label': 'Male'},
    {'id': 'female', 'label': 'Female'},
    {'id': 'other', 'label': 'Other'},
    {'id': 'prefer_not_to_say', 'label': 'Prefer not to say'},
  ];

  static const List<String> _timezoneOptions = [
    'Asia/Dhaka',
    'UTC',
    'Asia/Kolkata',
    'Asia/Dubai',
    'Asia/Singapore',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emergencyNameController = TextEditingController();
    _emergencyPhoneController = TextEditingController();
    _companyNameController = TextEditingController();
    _tradeLicenseController = TextEditingController();
    _billingAddressController = TextEditingController();

    _hydrateFromProfile(widget.controller.profile, force: true);
    widget.controller.addListener(_onControllerUpdated);
    widget.controller.loadCurrentUserIfNeeded();
  }

  void _onControllerUpdated() {
    if (!mounted) return;
    final profile = widget.controller.profile;
    if (profile != null &&
        (!_hasUnsavedChanges || _hydratedProfileId != profile.id)) {
      setState(() {
        _hydrateFromProfile(profile);
      });
    }
  }

  void _hydrateFromProfile(UserProfileModel? p, {bool force = false}) {
    if (p == null) return;
    if (!force && _hydratedProfileId == p.id && _hasUnsavedChanges) return;
    _hydratedProfileId = p.id;
    _nameController.text = p.fullName == 'SKAVIA Member' ? '' : p.fullName;
    _phoneController.text = p.phone ?? '';
    _emergencyNameController.text = p.emergencyContactName ?? '';
    _emergencyPhoneController.text = p.emergencyContactPhone ?? '';
    _companyNameController.text = p.companyName ?? '';
    _tradeLicenseController.text = p.tradeLicense ?? '';
    _billingAddressController.text = p.billingAddress ?? '';

    _selectedDob = p.dateOfBirth;
    _birthdayAlertsEnabled = p.birthdayNotificationsEnabled;
    _selectedGender = p.gender ?? 'prefer_not_to_say';
    _selectedLanguage = p.preferredLanguage;
    _selectedTimezone = p.timezone;
    _customerType = p.customerType;
    _avatarUrl = p.avatarUrl;
    _coverUrl = p.coverUrl;
    _hasUnsavedChanges = false;
  }

  void _markDirty() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdated);
    _nameController.dispose();
    _phoneController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _companyNameController.dispose();
    _tradeLicenseController.dispose();
    _billingAddressController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(1998, 1, 1),
      firstDate: DateTime(1940),
      lastDate: now,
      helpText: 'Select Date of Birth',
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<bool> _handlePopScope() async {
    if (_allowPop || !_hasUnsavedChanges) return true;

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Discard Unsaved Changes?',
      message: 'You have modified your profile details. Discard edits?',
      confirmText: 'Discard',
      isDestructive: true,
    );

    if (confirmed == true) {
      _allowPop = true;
      return true;
    }
    return false;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final current = widget.controller.profile;
    if (current == null) {
      UiFeedbackHelper.showError(context, 'Unable to identify active session.');
      return;
    }

    final ok = await widget.controller.updateProfile(
      fullName: _nameController.text.trim().isEmpty
          ? 'SKAVIA Member'
          : _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      avatarUrl: _avatarUrl,
      coverUrl: _coverUrl,
      gender: _selectedGender,
      dateOfBirth: _selectedDob,
      birthdayNotificationsEnabled: _birthdayAlertsEnabled,
      preferredLanguage: _selectedLanguage,
      timezone: _selectedTimezone,
      emergencyContactName: _emergencyNameController.text.trim().isEmpty
          ? null
          : _emergencyNameController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim().isEmpty
          ? null
          : _emergencyPhoneController.text.trim(),
      customerType: _customerType,
      companyName: _customerType == 'Individual'
          ? null
          : _companyNameController.text.trim(),
      tradeLicense: _customerType == 'Individual'
          ? null
          : _tradeLicenseController.text.trim(),
      billingAddress: _customerType == 'Individual'
          ? null
          : _billingAddressController.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      _hasUnsavedChanges = false;
      _allowPop = true;
      if (_selectedLanguage != AppLanguageService.localeNotifier.value) {
        AppLanguageService.setLanguage(_selectedLanguage);
      }
      if (!mounted) return;
      UiFeedbackHelper.showSuccess(context, 'Profile details saved.');
      Navigator.of(context).pop();
    } else {
      UiFeedbackHelper.showError(
        context,
        widget.controller.errorMessage ?? 'Unable to save profile changes.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = context.isBengali;

    return PopScope(
      canPop: !_hasUnsavedChanges || _allowPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _handlePopScope();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppAppBar(
          title: isBn ? 'ব্যক্তিগত তথ্য সম্পাদনা' : 'Edit Personal Details',
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              if (widget.controller.isLoading &&
                  widget.controller.profile == null) {
                return const ListShimmerSkeleton(itemCount: 4, itemHeight: 90);
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileAvatarPickerCard(
                        profile: widget.controller.profile,
                        avatarUrl: _avatarUrl,
                        onAvatarSelected: (url) {
                          setState(() {
                            _avatarUrl = url;
                            _hasUnsavedChanges = true;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ProfilePersonalDetailsSection(
                        nameController: _nameController,
                        phoneController: _phoneController,
                        emergencyNameController: _emergencyNameController,
                        emergencyPhoneController: _emergencyPhoneController,
                        selectedGender: _selectedGender,
                        genderOptions: _genderOptions,
                        onGenderChanged: (id) {
                          setState(() {
                            _selectedGender = id;
                            _hasUnsavedChanges = true;
                          });
                        },
                        onFieldChanged: _markDirty,
                      ),
                      const SizedBox(height: 20),
                      ProfilePreferencesSection(
                        selectedDob: _selectedDob,
                        birthdayAlertsEnabled: _birthdayAlertsEnabled,
                        selectedLanguage: _selectedLanguage,
                        selectedTimezone: _selectedTimezone,
                        timezoneOptions: _timezoneOptions,
                        onSelectDob: _selectDateOfBirth,
                        onBirthdayAlertsChanged: (val) {
                          setState(() {
                            _birthdayAlertsEnabled = val;
                            _hasUnsavedChanges = true;
                          });
                        },
                        onLanguageChanged: (lang) {
                          setState(() {
                            _selectedLanguage = lang;
                            _hasUnsavedChanges = true;
                          });
                        },
                        onTimezoneChanged: (tz) {
                          setState(() {
                            _selectedTimezone = tz;
                            _hasUnsavedChanges = true;
                          });
                        },
                      ),
                      const SizedBox(height: 22),
                      ProfileCorporateDetailsSection(
                        customerType: _customerType,
                        companyNameController: _companyNameController,
                        tradeLicenseController: _tradeLicenseController,
                        billingAddressController: _billingAddressController,
                        onCustomerTypeChanged: (type) {
                          setState(() {
                            _customerType = type;
                            _hasUnsavedChanges = true;
                          });
                        },
                        onFieldChanged: _markDirty,
                      ),
                      const SizedBox(height: 28),
                      AppButton(
                        text: isBn
                            ? 'তথ্য সংরক্ষণ করুন'
                            : 'Save Profile Details',
                        isLoading: widget.controller.isLoading,
                        onPressed: _handleSave,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
