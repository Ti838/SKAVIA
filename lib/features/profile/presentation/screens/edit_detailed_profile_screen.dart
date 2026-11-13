import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/dialogs/confirmation_dialog.dart';
import '../../../../shared/loaders/list_shimmer_skeleton.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../customer/presentation/widgets/avatar_picker_sheet.dart';
import '../../data/models/user_profile_model.dart';
import '../controllers/profile_controller.dart';

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
    _selectedGender = _genderOptions.any((g) => g['id'] == p.gender)
        ? (p.gender ?? 'prefer_not_to_say')
        : 'prefer_not_to_say';
    _selectedLanguage =
        (p.preferredLanguage == 'bn' || p.preferredLanguage == 'en')
            ? p.preferredLanguage
            : 'en';
    _selectedTimezone = _timezoneOptions.contains(p.timezone)
        ? p.timezone
        : 'Asia/Dhaka';
    _customerType = p.customerType;
    _avatarUrl = p.avatarUrl;
    _coverUrl = p.coverUrl;
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
    final initialDate =
        _selectedDob ?? DateTime(now.year - 25, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 15, now.month, now.day),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.controller.loadCurrentUserIfNeeded();

    final rawPhone = _phoneController.text.trim();
    final normalizedPhone = rawPhone.isEmpty
        ? null
        : Validators.normalizeBdPhone(rawPhone);
    final rawEmergPhone = _emergencyPhoneController.text.trim();
    final normalizedEmergPhone = rawEmergPhone.isEmpty
        ? null
        : Validators.normalizeBdPhone(rawEmergPhone);
    final isCorporate = _customerType != 'Individual';

    final success = await widget.controller.updateProfile(
      fullName: _nameController.text.trim(),
      phone: normalizedPhone,
      avatarUrl: _avatarUrl,
      coverUrl: _coverUrl,
      customerType: _customerType,
      companyName: isCorporate ? _companyNameController.text.trim() : null,
      tradeLicense: isCorporate ? _tradeLicenseController.text.trim() : null,
      billingAddress:
          isCorporate ? _billingAddressController.text.trim() : null,
      dateOfBirth: _selectedDob,
      birthdayNotificationsEnabled: _birthdayAlertsEnabled,
      gender: _selectedGender,
      emergencyContactName: _emergencyNameController.text.trim(),
      emergencyContactPhone: normalizedEmergPhone,
      preferredLanguage: _selectedLanguage,
      timezone: _selectedTimezone,
    );

    if (!mounted) return;
    if (success) {
      setState(() {
        _hasUnsavedChanges = false;
        _allowPop = true;
      });
      UiFeedbackHelper.showSuccess(context, 'Profile updated successfully!');
      Navigator.pop(context);
    } else {
      UiFeedbackHelper.showError(
        context,
        widget.controller.errorMessage ?? 'Unable to save profile details.',
      );
    }
  }

  Future<void> _confirmDiscardAndExit() async {
    final discard = await ConfirmationDialog.show(
      context,
      title: 'Discard Unsaved Changes?',
      message: 'You have edited your profile details. Leave without saving?',
      confirmText: 'Discard',
      cancelText: 'Keep Editing',
      isDestructive: true,
    );
    if (discard == true && mounted) {
      setState(() {
        _hasUnsavedChanges = false;
        _allowPop = true;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    final isBn = AppLanguageService.isBengali;

    return PopScope(
      canPop: _allowPop || !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _hasUnsavedChanges) {
          _confirmDiscardAndExit();
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
              final profile = widget.controller.profile;
              if (widget.controller.isLoading && profile == null) {
                return const ListShimmerSkeleton(itemCount: 4, itemHeight: 78);
              }

              final effectiveName = _nameController.text.trim().isNotEmpty
                  ? _nameController.text.trim()
                  : (profile?.fullName ?? 'SKAVIA Member');
              final effectiveAvatar = _avatarUrl ?? profile?.avatarUrl;
              final rawCover = _coverUrl ?? profile?.coverUrl;
              final effectiveCover =
                  (rawCover != null &&
                      rawCover.trim().isNotEmpty &&
                      (rawCover.startsWith('http://') ||
                          rawCover.startsWith('https://')))
                  ? rawCover.trim()
                  : null;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Facebook-style Profile Banner & Avatar Editor Card
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                AvatarPickerSheet.show(
                                  context,
                                  currentAvatarUrl: effectiveCover,
                                  userId: profile?.id,
                                  slot: ProfileMediaSlot.cover,
                                  onAvatarSelected: (url) {
                                    setState(() {
                                      _coverUrl = url;
                                      _hasUnsavedChanges = true;
                                    });
                                  },
                                );
                              },
                              child: Container(
                                height: 112,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: effectiveCover == null
                                      ? LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            colorScheme.primary.withValues(
                                              alpha: 0.85,
                                            ),
                                            colorScheme.secondary.withValues(
                                              alpha: 0.72,
                                            ),
                                          ],
                                        )
                                      : null,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (effectiveCover != null)
                                      Image.network(
                                        effectiveCover,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            const SizedBox.shrink(),
                                      ),
                                    Positioned(
                                      right: 8,
                                      bottom: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.56,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.panorama_outlined,
                                              color: Colors.white,
                                              size: 13,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              effectiveCover == null
                                                  ? (isBn
                                                        ? 'কভার যোগ করুন'
                                                        : 'Add Cover')
                                                  : (isBn
                                                        ? 'কভার বদলান'
                                                        : 'Edit Cover'),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 16,
                              runSpacing: 12,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                UserAvatar(
                                  imageUrl: effectiveAvatar,
                                  name: effectiveName,
                                  radius: 32,
                                  isVerified:
                                      profile?.verificationStatus == 'verified',
                                  onTap: () {
                                    AvatarPickerSheet.show(
                                      context,
                                      currentAvatarUrl: effectiveAvatar,
                                      userId: profile?.id,
                                      slot: ProfileMediaSlot.avatar,
                                      onAvatarSelected: (url) {
                                        setState(() {
                                          _avatarUrl = url;
                                          _hasUnsavedChanges = true;
                                        });
                                      },
                                    );
                                  },
                                ),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(minWidth: 160),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        effectiveName,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        profile?.email.isNotEmpty == true
                                            ? profile!.email
                                            : (isBn
                                                  ? 'ক্যামেরা বা গ্যালারি থেকে ছবি আপলোড করুন'
                                                  : 'Tap photo to upload from camera or gallery'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          AvatarPickerSheet.show(
                                            context,
                                            currentAvatarUrl: effectiveAvatar,
                                            userId: profile?.id,
                                            slot: ProfileMediaSlot.avatar,
                                            onAvatarSelected: (url) {
                                              setState(() {
                                                _avatarUrl = url;
                                                _hasUnsavedChanges = true;
                                              });
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 16,
                                        ),
                                        label: Text(
                                          isBn
                                              ? 'ছবি পরিবর্তন করুন'
                                              : 'Change Photo',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        isBn ? 'ব্যক্তিগত পরিচিতি' : 'Personal Identity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter your legal full name',
                        prefixIcon: const Icon(Icons.person_outline),
                        onChanged: (_) => _markDirty(),
                        validator: (val) =>
                            val == null || val.trim().length < 3
                            ? 'Please enter at least 3 characters'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: '+8801XXXXXXXXX or 017XXXXXXXX',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        keyboardType: TextInputType.phone,
                        onChanged: (_) => _markDirty(),
                        validator: Validators.optionalBdPhone,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Gender',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _genderOptions.map((opt) {
                          final id = opt['id']!;
                          final selected = _selectedGender == id;
                          return ChoiceChip(
                            label: Text(opt['label']!),
                            selected: selected,
                            onSelected: (v) {
                              if (v) {
                                setState(() {
                                  _selectedGender = id;
                                  _hasUnsavedChanges = true;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Date of Birth & Birthday Reminders
                      Text(
                        'Date of Birth & Birthday Gifts',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDateOfBirth,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: tokens.inputBg,
                            border: Border.all(color: tokens.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.cake_outlined,
                                      color: tokens.brandAccent,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Text(
                                        _selectedDob != null
                                            ? DateFormat(
                                                'dd MMMM yyyy',
                                              ).format(_selectedDob!)
                                            : 'Select your date of birth',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _selectedDob != null
                                              ? colorScheme.onSurface
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: tokens.brandAccent,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Receive Birthday Discount Perks',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'SKAVIA gifts 20% off on your birthday week',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: _birthdayAlertsEnabled,
                        activeThumbColor: tokens.brandAccent,
                        onChanged: (val) => setState(() {
                          _birthdayAlertsEnabled = val;
                          _hasUnsavedChanges = true;
                        }),
                      ),
                      const SizedBox(height: 16),

                      // Preferred Language & Timezone
                      Text(
                        'Language & Region',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ChoiceChip(
                            label: const Text('English'),
                            selected: _selectedLanguage == 'en',
                            onSelected: (v) {
                              if (v) {
                                setState(() {
                                  _selectedLanguage = 'en';
                                  _hasUnsavedChanges = true;
                                });
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('বাংলা (Bengali)'),
                            selected: _selectedLanguage == 'bn',
                            onSelected: (v) {
                              if (v) {
                                setState(() {
                                  _selectedLanguage = 'bn';
                                  _hasUnsavedChanges = true;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTimezone,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Timezone',
                          prefixIcon: const Icon(Icons.schedule_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        items: _timezoneOptions
                            .map(
                              (tz) => DropdownMenuItem(
                                value: tz,
                                child: Text(tz),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedTimezone = val;
                              _hasUnsavedChanges = true;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Emergency Contact
                      Text(
                        'Emergency Contact',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _emergencyNameController,
                        label: 'Contact Person Name',
                        hint: 'e.g. Spouse, Brother, Guardian',
                        prefixIcon: const Icon(Icons.contact_emergency_outlined),
                        onChanged: (_) => _markDirty(),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _emergencyPhoneController,
                        label: 'Emergency Phone Number',
                        hint: '+8801XXXXXXXXX or 017XXXXXXXX',
                        prefixIcon: const Icon(Icons.phone_in_talk_outlined),
                        keyboardType: TextInputType.phone,
                        onChanged: (_) => _markDirty(),
                        validator: Validators.optionalBdPhone,
                      ),
                      const SizedBox(height: 22),

                      // Client Account Classification & Corporate Details
                      Text(
                        'Account Classification',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: ['Individual', 'Business Client', 'Organization']
                            .map((type) {
                              final selected = _customerType == type;
                              return ChoiceChip(
                                label: Text(type),
                                selected: selected,
                                onSelected: (v) {
                                  if (v) {
                                    setState(() {
                                      _customerType = type;
                                      _hasUnsavedChanges = true;
                                    });
                                  }
                                },
                              );
                            })
                            .toList(),
                      ),
                      if (_customerType != 'Individual') ...[
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _companyNameController,
                          label: '$_customerType Name',
                          hint: 'Registered legal company or organization name',
                          prefixIcon: const Icon(Icons.business_outlined),
                          onChanged: (_) => _markDirty(),
                          validator: (val) =>
                              val == null || val.trim().length < 2
                              ? 'Enter organization name for corporate billing'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _tradeLicenseController,
                          label: 'Trade License / Registration No.',
                          hint: 'e.g. TRAD/DSCC/012345',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          onChanged: (_) => _markDirty(),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _billingAddressController,
                          label: 'Corporate Billing Address',
                          hint: 'Invoice recipient address for VAT statements',
                          prefixIcon: const Icon(Icons.receipt_long_outlined),
                          maxLines: 2,
                          onChanged: (_) => _markDirty(),
                        ),
                      ],
                      const SizedBox(height: 28),

                      AppButton(
                        text: isBn ? 'তথ্য সংরক্ষণ করুন' : 'Save Profile Details',
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
