import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../core/utils/uuid_util.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/dialogs/confirmation_dialog.dart';
import '../../../../shared/empty_states/empty_data_view.dart';
import '../../../../shared/loaders/list_shimmer_skeleton.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/models/user_address_model.dart';
import '../controllers/profile_controller.dart';

class SavedAddressesScreen extends StatefulWidget {
  final ProfileController controller;

  const SavedAddressesScreen({super.key, required this.controller});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadCurrentUserIfNeeded();
  }

  void _openAddAddressModal([UserAddressModel? editAddress]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressEditorSheet(
        controller: widget.controller,
        editAddress: editAddress,
      ),
    );
  }

  Future<void> _confirmDelete(UserAddressModel addr) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Saved Address?',
      message:
          'Remove "${addr.label}" (${addr.addressLine}) from your saved locations?',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (confirmed == true && mounted) {
      await widget.controller.deleteAddress(addr.id);
      if (mounted) {
        UiFeedbackHelper.showInfo(context, 'Address removed.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final addresses = widget.controller.profile?.savedAddresses ?? [];

        return Scaffold(
          appBar: const AppAppBar(title: 'Saved Delivery Addresses'),
          body: SafeArea(
            child: widget.controller.isLoading &&
                    widget.controller.profile == null
                ? const ListShimmerSkeleton(itemCount: 3, itemHeight: 110)
                : addresses.isEmpty
                    ? EmptyDataView(
                        icon: Icons.location_off_outlined,
                        title: 'No Addresses Saved Yet',
                        message:
                            'Add your home or office address to enable 1-tap service dispatch across Dhaka.',
                        actionText: '+ Add First Address',
                        onAction: () => _openAddAddressModal(),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.paddingLarge,
                          AppDimensions.paddingLarge,
                          AppDimensions.paddingLarge,
                          96,
                        ),
                        itemCount: addresses.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final addr = addresses[index];
                          IconData icon = Icons.home_rounded;
                          if (addr.label == 'Work' || addr.label == 'Office') {
                            icon = Icons.business_rounded;
                          } else if (addr.label == 'Other') {
                            icon = Icons.place_rounded;
                          }

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: tokens.cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: addr.isDefault
                                    ? tokens.brandAccent
                                    : tokens.border,
                                width: addr.isDefault ? 1.5 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: addr.isDefault
                                        ? tokens.brandAccent
                                              .withValues(alpha: 0.14)
                                        : colorScheme.surfaceContainerHighest,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    icon,
                                    color: addr.isDefault
                                        ? tokens.brandAccent
                                        : colorScheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            addr.label,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          if (addr.isDefault)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: tokens.brandAccent
                                                    .withValues(alpha: 0.14),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'DEFAULT',
                                                style: TextStyle(
                                                  color: tokens.brandAccent,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if ((addr.recipientName ?? '')
                                              .isNotEmpty ||
                                          (addr.recipientPhone ?? '')
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          [
                                            if ((addr.recipientName ?? '')
                                                .isNotEmpty)
                                              addr.recipientName!,
                                            if ((addr.recipientPhone ?? '')
                                                .isNotEmpty)
                                              addr.recipientPhone!,
                                          ].join(' • '),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Text(
                                        addr.addressLine,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${addr.zone}, ${addr.city} ${addr.postalCode ?? ''}'
                                            .trim(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: tokens.mutedText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  onSelected: (val) async {
                                    if (val == 'default') {
                                      await widget.controller
                                          .setDefaultAddress(addr);
                                      if (context.mounted) {
                                        UiFeedbackHelper.showSuccess(
                                          context,
                                          '${addr.label} set as primary address.',
                                        );
                                      }
                                    } else if (val == 'edit') {
                                      _openAddAddressModal(addr);
                                    } else if (val == 'delete') {
                                      await _confirmDelete(addr);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    if (!addr.isDefault)
                                      const PopupMenuItem(
                                        value: 'default',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.star_outline_rounded,
                                              size: 16,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Set as Default'),
                                          ],
                                        ),
                                      ),
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_outlined, size: 16),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline,
                                            color: AppColors.errorRed,
                                            size: 16,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: AppColors.errorRed,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          floatingActionButton: addresses.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () => _openAddAddressModal(),
                  backgroundColor: AppColors.primaryRoyal,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Address'),
                )
              : null,
        );
      },
    );
  }
}

class _AddressEditorSheet extends StatefulWidget {
  final ProfileController controller;
  final UserAddressModel? editAddress;

  const _AddressEditorSheet({
    required this.controller,
    this.editAddress,
  });

  @override
  State<_AddressEditorSheet> createState() => _AddressEditorSheetState();
}

class _AddressEditorSheetState extends State<_AddressEditorSheet> {
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
      text: edit?.recipientName ??
          (profile?.fullName != null && profile!.fullName != 'SKAVIA Member'
              ? profile.fullName
              : ''),
    );
    _recipientPhoneController = TextEditingController(
      text: edit?.recipientPhone ?? profile?.phone ?? '',
    );
    _addressLineController =
        TextEditingController(text: edit?.addressLine ?? '');
    _zoneController =
        TextEditingController(text: edit?.zone ?? 'Dhanmondi');
    _postalCodeController =
        TextEditingController(text: edit?.postalCode ?? '');
    _selectedLabel = edit?.label ?? 'Home';
    _isDefault = edit?.isDefault ??
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
                  onChanged: (val) =>
                      setState(() => _isDefault = val ?? false),
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
