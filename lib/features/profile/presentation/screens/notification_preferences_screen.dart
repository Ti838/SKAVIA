import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../controllers/profile_controller.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  final ProfileController controller;

  const NotificationPreferencesScreen({super.key, required this.controller});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final prefs = widget.controller.profile?.notificationPreferences ?? {};

    return Scaffold(
      appBar: const AppAppBar(
        title: 'Notification Preferences',
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          children: [
            Text(
              'Alert Channels',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            _buildToggleTile(
              title: 'Push Notifications',
              subtitle: 'Heads-up alerts on your device screen',
              keyName: 'push_enabled',
              prefs: prefs,
            ),
            _buildToggleTile(
              title: 'SMS Text Alerts',
              subtitle: 'Verification codes and critical arrival updates',
              keyName: 'sms_enabled',
              prefs: prefs,
            ),
            _buildToggleTile(
              title: 'Email Invoices & Statements',
              subtitle: 'Digital VAT receipts and monthly expense reports',
              keyName: 'email_enabled',
              prefs: prefs,
            ),
            const Divider(height: 32),
            Text(
              'Notification Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            _buildToggleTile(
              title: 'Urgent Dispatch & OTP Alerts',
              subtitle: 'Audio chimes and real-time arrival countdowns',
              keyName: 'urgent_alerts',
              prefs: prefs,
            ),
            _buildToggleTile(
              title: 'Birthday Reminders & Rewards',
              subtitle: 'Special celebratory discounts and vouchers',
              keyName: 'birthday_reminders',
              prefs: prefs,
            ),
            _buildToggleTile(
              title: 'Promotional Offers & Tips',
              subtitle: 'Occasional seasonal maintenance deals',
              keyName: 'promotional',
              prefs: prefs,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required String keyName,
    required Map<String, dynamic> prefs,
  }) {
    final isEnabled = prefs[keyName] as bool? ?? true;

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      value: isEnabled,
      activeThumbColor: AppColors.primaryRoyal,
      onChanged: (val) {
        widget.controller.toggleNotificationPreference(keyName, val);
        setState(() {});
      },
    );
  }
}
