import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// Personal Identity and Emergency Contact section for EditDetailedProfileScreen.
class ProfilePersonalDetailsSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emergencyNameController;
  final TextEditingController emergencyPhoneController;
  final String selectedGender;
  final List<Map<String, String>> genderOptions;
  final ValueChanged<String> onGenderChanged;
  final VoidCallback onFieldChanged;

  const ProfilePersonalDetailsSection({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emergencyNameController,
    required this.emergencyPhoneController,
    required this.selectedGender,
    required this.genderOptions,
    required this.onGenderChanged,
    required this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isBn = context.isBengali;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          controller: nameController,
          label: 'Full Name',
          hint: 'Enter your legal full name',
          prefixIcon: const Icon(Icons.person_outline),
          onChanged: (_) => onFieldChanged(),
          validator: (val) =>
              val == null || val.trim().length < 3
              ? 'Please enter at least 3 characters'
              : null,
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: phoneController,
          label: 'Phone Number',
          hint: '+8801XXXXXXXXX or 017XXXXXXXX',
          prefixIcon: const Icon(Icons.phone_outlined),
          keyboardType: TextInputType.phone,
          onChanged: (_) => onFieldChanged(),
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
          children: genderOptions.map((opt) {
            final id = opt['id']!;
            final selected = selectedGender == id;
            return ChoiceChip(
              label: Text(opt['label']!),
              selected: selected,
              onSelected: (v) {
                if (v) onGenderChanged(id);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
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
          controller: emergencyNameController,
          label: 'Contact Person Name',
          hint: 'e.g. Spouse, Brother, Guardian',
          prefixIcon: const Icon(Icons.contact_emergency_outlined),
          onChanged: (_) => onFieldChanged(),
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: emergencyPhoneController,
          label: 'Emergency Phone Number',
          hint: '+8801XXXXXXXXX or 017XXXXXXXX',
          prefixIcon: const Icon(Icons.phone_in_talk_outlined),
          keyboardType: TextInputType.phone,
          onChanged: (_) => onFieldChanged(),
          validator: Validators.optionalBdPhone,
        ),
      ],
    );
  }
}
