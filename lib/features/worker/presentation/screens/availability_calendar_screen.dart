import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/widgets/app_button.dart';

/// Screen allowing specialists to manage their working hours, shifts, and active availability slots.
/// Inspired by Connecteam & Taskrabbit availability management.
class AvailabilityCalendarScreen extends StatefulWidget {
  const AvailabilityCalendarScreen({super.key});

  @override
  State<AvailabilityCalendarScreen> createState() =>
      _AvailabilityCalendarScreenState();
}

class _AvailabilityCalendarScreenState
    extends State<AvailabilityCalendarScreen> {
  bool _isAvailableForDispatches = true;
  bool _emergencyCallsEnabled = true;

  final Map<String, bool> _days = {
    'Saturday': true,
    'Sunday': true,
    'Monday': true,
    'Tuesday': true,
    'Wednesday': true,
    'Thursday': true,
    'Friday': false,
  };

  final Map<String, bool> _slots = {
    'Morning (08:00 AM – 12:00 PM)': true,
    'Afternoon (12:00 PM – 05:00 PM)': true,
    'Evening (05:00 PM – 09:00 PM)': true,
    'Late Night (09:00 PM – 12:00 AM)': false,
  };

  void _saveAvailability() {
    UiFeedbackHelper.showSuccess(
      context,
      'Working schedule updated! Real-time matching engine updated with your active slots.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Availability & Shifts',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Master Availability Toggle
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              decoration: BoxDecoration(
                color: _isAvailableForDispatches
                    ? AppColors.successGreen.withValues(alpha: 0.1)
                    : (isDark
                          ? colorScheme.surfaceContainerHighest
                          : AppColors.sheetSurfaceSubtle),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                border: Border.all(
                  color: _isAvailableForDispatches
                      ? AppColors.successGreen
                      : colorScheme.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isAvailableForDispatches
                          ? AppColors.successGreen
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isAvailableForDispatches
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isAvailableForDispatches
                              ? 'On-Duty (Available for Jobs)'
                              : 'Off-Duty (Paused)',
                          style: TextStyle(
                            fontFamily: AppTypography.headingFont,
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isAvailableForDispatches
                              ? 'You receive instant nearby customer requests'
                              : 'You are temporarily hidden from new search results',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isAvailableForDispatches,
                    activeThumbColor: AppColors.successGreen,
                    onChanged: (val) =>
                        setState(() => _isAvailableForDispatches = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),

            // Emergency Dispatch Toggle
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceContainerHighest
                    : AppColors.sheetSurfaceSubtle,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    color: AppColors.accent,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '24/7 Emergency Dispatch Pool',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Earn +25% premium for rapid response callouts',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _emergencyCallsEnabled,
                    activeThumbColor: AppColors.accent,
                    onChanged: (val) =>
                        setState(() => _emergencyCallsEnabled = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXLarge),

            // Working Days
            Text(
              'Weekly Working Schedule',
              style: TextStyle(
                fontFamily: AppTypography.headingFont,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _days.keys.map((day) {
                final isSelected = _days[day]!;
                return FilterChip(
                  label: Text(day),
                  selected: isSelected,
                  selectedColor: AppColors.primarySky.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primaryRoyal,
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryRoyal
                        : colorScheme.onSurface,
                    fontSize: 12.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onSelected: (val) => setState(() => _days[day] = val),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.paddingXLarge),

            // Time Slots
            Text(
              'Active Work Slots',
              style: TextStyle(
                fontFamily: AppTypography.headingFont,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            ..._slots.keys.map((slot) {
              final isEnabled = _slots[slot]!;
              return CheckboxListTile(
                value: isEnabled,
                title: Text(
                  slot,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: colorScheme.onSurface,
                  ),
                ),
                activeColor: AppColors.primaryRoyal,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (val) {
                  if (val != null) setState(() => _slots[slot] = val);
                },
              );
            }),
            const SizedBox(height: AppDimensions.paddingXLarge),

            AppButton(
              text: 'Save Availability Preferences',
              onPressed: _saveAvailability,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
