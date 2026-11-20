import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';

/// Inputs for Service Address and optional Special Instructions/Gate Code.
class BookingAddressNotesCard extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController notesController;

  const BookingAddressNotesCard({
    super.key,
    required this.addressController,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;
    final isBn = context.isBengali;

    return Column(
      children: [
        // Service Address input
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tokens.subtleCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: tokens.border),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: tokens.brandAccent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText: isBn
                        ? 'কাজের ঠিকানা (যেমন: ধানমন্ডি, ঢাকা)'
                        : 'Service Address (e.g. Dhaka, Bangladesh)',
                    border: InputBorder.none,
                    isDense: true,
                    hintStyle: TextStyle(
                      fontSize: 12.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Optional access / job notes input
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tokens.subtleCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: tokens.border),
          ),
          child: Row(
            children: [
              Icon(
                Icons.notes_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    hintText: isBn
                        ? 'বিশেষ নির্দেশনা বা গেট কোড (ঐচ্ছিক)'
                        : 'Special instructions or gate code (optional)',
                    border: InputBorder.none,
                    isDense: true,
                    hintStyle: TextStyle(
                      fontSize: 12.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
