import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/utils/uuid_util.dart';
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
  void _openAddAddressModal([UserAddressModel? editAddress]) {
    final formKey = GlobalKey<FormState>();
    final addressLineController =
        TextEditingController(text: editAddress?.addressLine ?? '');
    final zoneController =
        TextEditingController(text: editAddress?.zone ?? 'Dhaka North');
    final postalCodeController =
        TextEditingController(text: editAddress?.postalCode ?? '');
    String selectedLabel = editAddress?.label ?? 'Home';
    bool isDefault = editAddress?.isDefault ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      editAddress != null ? 'Edit Address' : 'Add New Address',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Label selector pills
                Row(
                  children: ['Home', 'Work', 'Office', 'Other'].map((label) {
                    final isSel = selectedLabel == label;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSel,
                        selectedColor:
                            AppColors.primaryRoyal.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: isSel
                              ? AppColors.primaryRoyal
                              : Colors.grey.shade700,
                          fontWeight:
                              isSel ? FontWeight.w700 : FontWeight.w500,
                        ),
                        onSelected: (val) {
                          if (val) setModalState(() => selectedLabel = label);
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                AppTextField(
                  controller: addressLineController,
                  label: 'Street Address',
                  hint: 'House/Flat #, Road #, Area',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  validator: (val) => val == null || val.trim().length < 5
                      ? 'Please enter detailed address'
                      : null,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        controller: zoneController,
                        label: 'Zone / Sector',
                        hint: 'e.g. Gulshan-2, Uttara Sec 4',
                        prefixIcon: const Icon(Icons.map_outlined),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppTextField(
                        controller: postalCodeController,
                        label: 'Postal Code',
                        hint: '1212',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Set as primary delivery address',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  value: isDefault,
                  activeColor: AppColors.primaryRoyal,
                  onChanged: (val) =>
                      setModalState(() => isDefault = val ?? false),
                ),
                const SizedBox(height: 16),

                AppButton(
                  text: editAddress != null ? 'Update Address' : 'Save Address',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final userId = widget.controller.profile?.id ?? '';
                    final newAddr = UserAddressModel(
                      id: editAddress?.id ?? UuidUtil.generateUuidV4(),
                      userId: userId,
                      label: selectedLabel,
                      addressLine: addressLineController.text.trim(),
                      zone: zoneController.text.trim(),
                      city: 'Dhaka',
                      postalCode: postalCodeController.text.trim(),
                      isDefault: isDefault,
                    );
                    Navigator.pop(ctx);
                    await widget.controller.addOrUpdateAddress(newAddr);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final addresses = widget.controller.profile?.savedAddresses ?? [];

    return Scaffold(
      appBar: const AppAppBar(
        title: 'Saved Delivery Addresses',
      ),
      body: SafeArea(
        child: addresses.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primarySky.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_off_outlined,
                          size: 48,
                          color: AppColors.primaryRoyal,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Addresses Saved Yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Add your home or office address to enable instant doorstep service booking.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        text: '+ Add First Address',
                        onPressed: () => _openAddAddressModal(),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
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
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: addr.isDefault
                            ? AppColors.primaryRoyal
                            : colorScheme.outlineVariant,
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
                                ? AppColors.primaryRoyal.withValues(alpha: 0.12)
                                : colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: addr.isDefault
                                ? AppColors.primaryRoyal
                                : colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    addr.label,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  if (addr.isDefault) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryRoyal
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'DEFAULT',
                                        style: TextStyle(
                                          color: AppColors.primaryRoyal,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
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
                                '${addr.zone}, ${addr.city} ${addr.postalCode ?? ''}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.8),
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
                          onSelected: (val) {
                            if (val == 'edit') {
                              _openAddAddressModal(addr);
                            } else if (val == 'delete') {
                              widget.controller.deleteAddress(addr.id);
                              setState(() {});
                            }
                          },
                          itemBuilder: (context) => [
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
                                    style: TextStyle(color: AppColors.errorRed),
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
  }
}
