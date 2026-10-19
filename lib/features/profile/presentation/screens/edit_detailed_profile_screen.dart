import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
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

  DateTime? _selectedDob;
  bool _birthdayAlertsEnabled = true;
  String _selectedGender = 'prefer_not_to_say';
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    final p = widget.controller.profile;
    _nameController = TextEditingController(text: p?.fullName ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _emergencyNameController =
        TextEditingController(text: p?.emergencyContactName ?? '');
    _emergencyPhoneController =
        TextEditingController(text: p?.emergencyContactPhone ?? '');
    _selectedDob = p?.dateOfBirth;
    _birthdayAlertsEnabled = p?.birthdayNotificationsEnabled ?? true;
    _selectedGender = p?.gender ?? 'prefer_not_to_say';
    _selectedLanguage = p?.preferredLanguage ?? 'en';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
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
      setState(() => _selectedDob = picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.controller.updateProfile(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      dateOfBirth: _selectedDob,
      birthdayNotificationsEnabled: _birthdayAlertsEnabled,
      gender: _selectedGender,
      emergencyContactName: _emergencyNameController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim(),
      preferredLanguage: _selectedLanguage,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppAppBar(
        title: 'Edit Personal Details',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Identity',
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
                  validator: (val) => val == null || val.trim().length < 3
                      ? 'Please enter your full name'
                      : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '+8801XXXXXXXXX',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
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
                      border: Border.all(color: colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.cake_outlined,
                              color: AppColors.primaryRoyal,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDob != null
                                  ? DateFormat('dd MMMM yyyy')
                                      .format(_selectedDob!)
                                  : 'Select your date of birth',
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedDob != null
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.primaryRoyal,
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
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'SKAVIA gifts 20% off on your birthday week',
                    style: TextStyle(fontSize: 11),
                  ),
                  value: _birthdayAlertsEnabled,
                  activeThumbColor: AppColors.primaryRoyal,
                  onChanged: (val) =>
                      setState(() => _birthdayAlertsEnabled = val),
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
                  hint: 'e.g. Spouse, Brother, Father',
                  prefixIcon: const Icon(Icons.contact_emergency_outlined),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _emergencyPhoneController,
                  label: 'Emergency Phone Number',
                  hint: '+8801XXXXXXXXX',
                  prefixIcon: const Icon(Icons.phone_in_talk_outlined),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 32),

                AppButton(
                  text: 'Save Profile Details',
                  isLoading: widget.controller.isLoading,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
