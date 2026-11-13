import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
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
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    final locationPicker = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isBn ? 'এলাকা (ঢাকা)' : 'Location Zone',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: tokens.subtleCardBg,
            border: Border.all(color: tokens.border),
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
              dropdownColor: tokens.cardBg,
              items: LocationService.dhakaZones.map((z) {
                return DropdownMenuItem(
                  value: z,
                  child: Text(
                    z,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onLocationChanged('$val, Dhaka');
              },
            ),
          ),
        ),
      ],
    );

    final budgetInput = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isBn ? 'বাজেট (৳ BDT)' : 'Budget (৳ BDT)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: budgetController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: '1500',
            filled: true,
            fillColor: tokens.subtleCardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: tokens.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );

    Widget buildUrgencyPill({
      required String value,
      required String label,
      required bool isEmergency,
    }) {
      final isSelected = urgency == value;
      final activeBg = isEmergency
          ? AppColors.accentCoral.withValues(alpha: 0.16)
          : tokens.softBlueBg;
      final activeBorder =
          isEmergency ? AppColors.accentCoral : tokens.brandAccent;
      final activeText =
          isEmergency ? AppColors.accentCoral : tokens.brandAccent;

      return Material(
        color: isSelected ? activeBg : tokens.subtleCardBg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onUrgencyChanged(value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? activeBorder : tokens.border,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeText : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Field
        Text(
          isBn ? 'শিরোনাম' : 'Title',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: titleController,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: isBn
                ? 'যেমন: ধানমন্ডিতে ৩-টন এসি গ্যাস রিফিল প্রয়োজন'
                : 'e.g. 3-Ton Split AC Gas Refill & Compressor Check',
            filled: true,
            fillColor: tokens.subtleCardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: tokens.border),
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
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: tokens.subtleCardBg,
            border: Border.all(color: tokens.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: categories.containsKey(selectedCategory)
                  ? selectedCategory
                  : categories.keys.first,
              isExpanded: true,
              dropdownColor: tokens.cardBg,
              items: categories.entries.map((e) {
                return DropdownMenuItem(
                  value: e.key,
                  child: Text(
                    AppLanguageService.getCategoryName(e.key, e.value),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colorScheme.onSurface),
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

        // Location & Budget Row (adapts vertically on compact viewports or high text scale)
        LayoutBuilder(
          builder: (context, constraints) {
            final stackFields = constraints.maxWidth < 330 || textScale > 1.35;
            if (stackFields) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  locationPicker,
                  const SizedBox(height: 14),
                  budgetInput,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: locationPicker),
                const SizedBox(width: 12),
                Expanded(child: budgetInput),
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        // Urgency
        Text(
          isBn ? 'জরুরিতা' : 'Urgency',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            buildUrgencyPill(
              value: 'Standard',
              label: isBn ? 'স্ট্যান্ডার্ড' : 'Standard',
              isEmergency: false,
            ),
            buildUrgencyPill(
              value: 'Emergency',
              label: isBn ? 'জরুরি (Emergency)' : 'Emergency (Within 2h)',
              isEmergency: true,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Description
        Text(
          isBn ? 'বিস্তারিত বর্ণনা' : 'Detailed Description',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: descController,
          maxLines: 4,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: isBn
                ? 'কাজের বিস্তারিত বিবরণ, প্রয়োজনীয় টুলস বা সমস্যা উল্লেখ করুন...'
                : 'Describe the issue, work scope, or technical requirement in detail...',
            filled: true,
            fillColor: tokens.subtleCardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: tokens.border),
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

