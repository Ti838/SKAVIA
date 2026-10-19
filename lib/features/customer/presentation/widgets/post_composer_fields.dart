import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/services/location_service.dart';

/// Form fields for PostComposerSheet: Category, Location, Budget, Urgency & Description.
class PostComposerFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descController;
  final TextEditingController budgetController;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final String selectedLocation;
  final ValueChanged<String> onLocationChanged;
  final String urgency;
  final ValueChanged<String> onUrgencyChanged;
  final Map<String, String> categories;

  const PostComposerFields({
    super.key,
    required this.titleController,
    required this.descController,
    required this.budgetController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.selectedLocation,
    required this.onLocationChanged,
    required this.urgency,
    required this.onUrgencyChanged,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Field
        Text(
          isBn ? 'শিরোনাম' : 'Title',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: isBn
                ? 'যেমন: ধানমন্ডিতে ৩-টন এসি গ্যাস রিফিল প্রয়োজন'
                : 'e.g. 3-Ton Split AC Gas Refill & Compressor Check',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Title is required' : null,
        ),
        const SizedBox(height: 16),

        // Category Selector
        Text(
          isBn ? 'ট্রেড ক্যাটাগরি' : 'Trade Category',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              items: categories.entries.map((e) {
                return DropdownMenuItem(
                  value: e.key,
                  child: Text(
                    AppLanguageService.getCategoryName(e.key, e.value),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onCategoryChanged(val);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Location & Budget Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn ? 'এলাকা (ঢাকা)' : 'Location Zone',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderLight),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: LocationService.dhakaZones.contains(
                          selectedLocation.split(',').first.trim(),
                        )
                            ? selectedLocation.split(',').first.trim()
                            : 'Dhanmondi',
                        isExpanded: true,
                        items: LocationService.dhakaZones.map((z) {
                          return DropdownMenuItem(value: z, child: Text(z));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) onLocationChanged('$val, Dhaka');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn ? 'বাজেট (৳ BDT)' : 'Budget (৳ BDT)',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '1500',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Urgency
        Text(
          isBn ? 'জরুরিতা' : 'Urgency',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            ChoiceChip(
              label: Text(isBn ? 'স্ট্যান্ডার্ড' : 'Standard'),
              selected: urgency == 'Standard',
              onSelected: (_) => onUrgencyChanged('Standard'),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(
                isBn ? 'জরুরি (Emergency)' : 'Emergency (Within 2h)',
              ),
              selected: urgency == 'Emergency',
              selectedColor: AppColors.accentCoral.withValues(alpha: 0.2),
              onSelected: (_) => onUrgencyChanged('Emergency'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Description
        Text(
          isBn ? 'বিস্তারিত বর্ণনা' : 'Detailed Description',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: descController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: isBn
                ? 'কাজের বিস্তারিত বিবরণ, প্রয়োজনীয় টুলস বা সমস্যা উল্লেখ করুন...'
                : 'Describe the issue, work scope, or technical requirement in detail...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Description is required'
              : null,
        ),
      ],
    );
  }
}

