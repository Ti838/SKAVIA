import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_text_field.dart';

/// Corporate Account Classification and Trade Details for EditDetailedProfileScreen.
class ProfileCorporateDetailsSection extends StatelessWidget {
  final String customerType;
  final TextEditingController companyNameController;
  final TextEditingController tradeLicenseController;
  final TextEditingController billingAddressController;
  final ValueChanged<String> onCustomerTypeChanged;
  final VoidCallback onFieldChanged;

  const ProfileCorporateDetailsSection({
    super.key,
    required this.customerType,
    required this.companyNameController,
    required this.tradeLicenseController,
    required this.billingAddressController,
    required this.onCustomerTypeChanged,
    required this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                final selected = customerType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: selected,
                  onSelected: (v) {
                    if (v) onCustomerTypeChanged(type);
                  },
                );
              })
              .toList(),
        ),
        if (customerType != 'Individual') ...[
          const SizedBox(height: 14),
          AppTextField(
            controller: companyNameController,
            label: '$customerType Name',
            hint: 'Registered legal company or organization name',
            prefixIcon: const Icon(Icons.business_outlined),
            onChanged: (_) => onFieldChanged(),
            validator: (val) =>
                val == null || val.trim().length < 2
                ? 'Enter organization name for corporate billing'
                : null,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: tradeLicenseController,
            label: 'Trade License / Registration No.',
            hint: 'e.g. TRAD/DSCC/012345',
            prefixIcon: const Icon(Icons.badge_outlined),
            onChanged: (_) => onFieldChanged(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: billingAddressController,
            label: 'Corporate Billing Address',
            hint: 'Invoice recipient address for VAT statements',
            prefixIcon: const Icon(Icons.receipt_long_outlined),
            maxLines: 2,
            onChanged: (_) => onFieldChanged(),
          ),
        ],
      ],
    );
  }
}
