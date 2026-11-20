import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../core/utils/uuid_util.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/models/user_address_model.dart';
import '../controllers/profile_controller.dart';

/// Modal bottom sheet to create or edit delivery and service addresses.
class AddressEditorSheet extends StatefulWidget {
  final ProfileController controller;
  final UserAddressModel? editAddress;

  const AddressEditorSheet({
    super.key,
    required this.controller,
    this.editAddress,
  });

  static Future<void> show(
    BuildContext context, {
    required ProfileController controller,
    UserAddressModel? editAddress,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          AddressEditorSheet(controller: controller, editAddress: editAddress),
    );
  }

  @override
  State<AddressEditorSheet> createState() => _AddressEditorSheetState();
}

class _AddressEditorSheetState extends State<AddressEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _recipientNameController;
  late final TextEditingController _recipientPhoneController;
  late final TextEditingController _addressLineController;
  late final TextEditingController _zoneController;
  late final TextEditingController _postalCodeController;

  late String _selectedLabel;
  late bool _isDefault;
  double? _latitude;
  double? _longitude;
  bool _isDetectingGps = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final edit = widget.editAddress;
    final profile = widget.controller.profile;
    _recipientNameController = TextEditingController(
      text:
          edit?.recipientName ??
          (profile?.fullName != null && profile!.fullName != 'SKAVIA Member'
              ? profile.fullName
              : ''),
    );
    _recipientPhoneController = TextEditingController(
      text: edit?.recipientPhone ?? profile?.phone ?? '',
    );
    _addressLineController = TextEditingController(
      text: edit?.addressLine ?? '',
    );
    _zoneController = TextEditingController(text: edit?.zone ?? 'Dhanmondi');
    _postalCodeController = TextEditingController(text: edit?.postalCode ?? '');
    _selectedLabel = edit?.label ?? 'Home';
    _isDefault =
        edit?.isDefault ??
        (widget.controller.profile?.savedAddresses.isEmpty ?? true);
    _latitude = edit?.latitude;
    _longitude = edit?.longitude;
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _addressLineController.dispose();
    _zoneController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _detectGpsAddress() async {
    if (_isDetectingGps) return;
    setState(() => _isDetectingGps = true);
    try {
      final result = await LocationService.getRealTimeLocation();
      if (!mounted) return;
      setState(() {
        _addressLineController.text = result.formattedAddress;
        _zoneController.text = result.zone;
        _latitude = result.latitude;
        _longitude = result.longitude;
        _isDetectingGps = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isDetectingGps = false);
      }
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    setState(() => _isSaving = true);
    await widget.controller.loadCurrentUserIfNeeded();
    final userId = widget.controller.profile?.id ?? 'guest';
    final rawPhone = _recipientPhoneController.text.trim();
    final newAddr = UserAddressModel(
      id: widget.editAddress?.id ?? UuidUtil.generateUuidV4(),
      userId: userId,
      label: _selectedLabel,
      recipientName: _recipientNameController.text.trim().isEmpty
          ? null
          : _recipientNameController.text.trim(),
      recipientPhone: rawPhone.isEmpty
          ? null
          : Validators.normalizeBdPhone(rawPhone),
      addressLine: _addressLineController.text.trim(),
      zone: _zoneController.text.trim().isEmpty
          ? 'Dhaka'
          : _zoneController.text.trim(),
      city: 'Dhaka',
      postalCode: _postalCodeController.text.trim().isEmpty
          ? null
          : _postalCodeController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      isDefault: _isDefault,
      createdAt: widget.editAddress?.createdAt ?? DateTime.now(),
    );

    final ok = await widget.controller.addOrUpdateAddress(newAddr);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) {
      Navigator.pop(context);
      UiFeedbackHelper.showSuccess(
        context,
        widget.editAddress != null ? 'Address updated.' : 'Address saved.',
      );
    } else {
      UiFeedbackHelper.showError(context, 'Could not save address.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;

    return Container(
      decoration: BoxDecoration(
        color: tokens.sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.editAddress != null
                            ? 'Edit Address'
                            : 'Add New Address',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: ['Home', 'Work', 'Office', 'Other'].map((label) {
                    final isSel = _selectedLabel == label;
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSel,
                      selectedColor: tokens.brandAccent.withValues(alpha: 0.18),
                      labelStyle: TextStyle(
                        color: isSel
                            ? tokens.brandAccent
                            : colorScheme.onSurfaceVariant,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedLabel = label);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isDetectingGps ? null : _detectGpsAddress,
                  icon: _isDetectingGps
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.my_location_rounded,
                          size: 16,
                          color: tokens.brandAccent,
                        ),
                  label: Text(
                    _isDetectingGps
                        ? 'Detecting Current Location...'
                        : 'Use Current GPS Location',
                  ),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _recipientNameController,
                  label: 'Contact Person Name',
                  hint: 'Who will coordinate on arrival?',
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _recipientPhoneController,
                  label: 'Contact Phone Number',
                  hint: '+8801XXXXXXXXX or 017XXXXXXXX',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                  validator: Validators.optionalBdPhone,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _addressLineController,
                  label: 'Street Address',
                  hint: 'House/Flat #, Road #, Area',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  validator: (val) => val == null || val.trim().length < 5
                      ? 'Please enter detailed address'
                      : null,
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final textScale = MediaQuery.textScalerOf(context).scale(1);
                    final stack =
                        constraints.maxWidth < 340 || textScale > 1.35;
                    final zoneField = AppTextField(
                      controller: _zoneController,
                      label: 'Zone / Sector',
                      hint: 'e.g. Dhanmondi, Gulshan',
                      prefixIcon: const Icon(Icons.map_outlined),
                    );
                    final postalField = AppTextField(
                      controller: _postalCodeController,
                      label: 'Postal Code',
                      hint: '1209',
                      keyboardType: TextInputType.number,
                    );
                    if (stack) {
                      return Column(
                        children: [
                          zoneField,
                          const SizedBox(height: 12),
                          postalField,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(flex: 2, child: zoneField),
                        const SizedBox(width: 8),
                        Expanded(child: postalField),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Set as primary service address',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  value: _isDefault,
                  activeColor: tokens.brandAccent,
                  onChanged: (val) => setState(() => _isDefault = val ?? false),
                ),
                const SizedBox(height: 14),
                AppButton(
                  text: widget.editAddress != null
                      ? 'Update Address'
                      : 'Save Address',
                  isLoading: _isSaving,
                  onPressed: _saveAddress,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
