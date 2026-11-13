import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../data/tables/database_tables.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_button.dart';

/// Screen allowing specialists to manage their working hours, shifts, and active availability slots.
class AvailabilityCalendarScreen extends StatefulWidget {
  const AvailabilityCalendarScreen({super.key});

  @override
  State<AvailabilityCalendarScreen> createState() =>
      _AvailabilityCalendarScreenState();
}

class _AvailabilityCalendarScreenState
    extends State<AvailabilityCalendarScreen> {
  static const String _cacheKey = 'worker_availability_prefs_v1';

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

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    final cached = LocalCacheService.instance.get(_cacheKey);
    if (cached is Map) {
      if (cached['available'] is bool) {
        _isAvailableForDispatches = cached['available'] as bool;
      }
      if (cached['emergency'] is bool) {
        _emergencyCallsEnabled = cached['emergency'] as bool;
      }
      if (cached['days'] is Map) {
        (cached['days'] as Map).forEach((k, v) {
          if (_days.containsKey(k.toString()) && v is bool) {
            _days[k.toString()] = v;
          }
        });
      }
      if (cached['slots'] is Map) {
        (cached['slots'] as Map).forEach((k, v) {
          if (_slots.containsKey(k.toString()) && v is bool) {
            _slots[k.toString()] = v;
          }
        });
      }
    }
  }

  Future<void> _saveAvailability() async {
    LocalCacheService.instance.put(_cacheKey, {
      'available': _isAvailableForDispatches,
      'emergency': _emergencyCallsEnabled,
      'days': _days,
      'slots': _slots,
    });

    final client = tryGetSupabaseClient();
    if (client != null) {
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await client
              .from(DatabaseTables.workerProfiles)
              .update({
                'is_available': _isAvailableForDispatches,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('user_id', uid);
        }
      } catch (e) {
        debugPrint('[AvailabilityCalendar] Sync notice: $e');
      }
    }

    if (!mounted) return;
    UiFeedbackHelper.showSuccess(
      context,
      'Working schedule saved! Dispatch availability updated.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: tokens.sheetBg,
      appBar: const AppAppBar(
        title: 'Availability & Shifts',
        centerTitle: true,
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
                    ? AppColors.successGreen.withValues(alpha: 0.12)
                    : tokens.subtleCardBg,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                border: Border.all(
                  color: _isAvailableForDispatches
                      ? AppColors.successGreen
                      : tokens.border,
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
                          : tokens.mutedText,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isAvailableForDispatches
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isAvailableForDispatches
                              ? 'On-Duty (Available)'
                              : 'Off-Duty (Paused)',
                          style: TextStyle(
                            fontFamily: AppTypography.headingFont,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isAvailableForDispatches
                              ? 'Receiving nearby customer requests'
                              : 'Hidden from new search dispatches',
                          style: TextStyle(
                            fontSize: 12,
                            color: tokens.secondaryText,
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
                color: tokens.subtleCardBg,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: tokens.border),
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
                            color: tokens.secondaryText,
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
                  selectedColor: tokens.softBlueBg,
                  checkmarkColor: tokens.brandAccent,
                  side: BorderSide(
                    color: isSelected ? tokens.brandAccent : tokens.border,
                  ),
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? tokens.brandAccent
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
                activeColor: tokens.brandAccent,
                checkColor: tokens.onBrandAccent,
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
