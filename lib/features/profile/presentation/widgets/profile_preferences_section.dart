import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/context_extensions.dart';

/// Preferences & Regional Localization Section for EditDetailedProfileScreen.
class ProfilePreferencesSection extends StatelessWidget {
  final DateTime? selectedDob;
  final bool birthdayAlertsEnabled;
  final String selectedLanguage;
  final String selectedTimezone;
  final List<String> timezoneOptions;
  final VoidCallback onSelectDob;
  final ValueChanged<bool> onBirthdayAlertsChanged;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<String> onTimezoneChanged;

  const ProfilePreferencesSection({
    super.key,
    required this.selectedDob,
    required this.birthdayAlertsEnabled,
    required this.selectedLanguage,
    required this.selectedTimezone,
    required this.timezoneOptions,
    required this.onSelectDob,
    required this.onBirthdayAlertsChanged,
    required this.onLanguageChanged,
    required this.onTimezoneChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          onTap: onSelectDob,
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
                          selectedDob != null
                              ? DateFormat('dd MMMM yyyy').format(selectedDob!)
                              : 'Select your date of birth',
                          style: TextStyle(
                            fontSize: 14,
                            color: selectedDob != null
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
          value: birthdayAlertsEnabled,
          activeThumbColor: tokens.brandAccent,
          onChanged: onBirthdayAlertsChanged,
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
              selected: selectedLanguage == 'en',
              onSelected: (v) {
                if (v) onLanguageChanged('en');
              },
            ),
            ChoiceChip(
              label: const Text('বাংলা (Bengali)'),
              selected: selectedLanguage == 'bn',
              onSelected: (v) {
                if (v) onLanguageChanged('bn');
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: selectedTimezone,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Timezone',
            prefixIcon: const Icon(Icons.schedule_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          items: timezoneOptions
              .map(
                (tz) => DropdownMenuItem(
                  value: tz,
                  child: Text(tz),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) onTimezoneChanged(val);
          },
        ),
      ],
    );
  }
}
