import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/sound_haptic_preferences.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_card.dart';
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
  void initState() {
    super.initState();
    widget.controller.loadCurrentUserIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    final soundPrefs = SoundHapticPreferences.instance;

    return Scaffold(
      appBar: const AppAppBar(title: 'Notification Preferences'),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([widget.controller, soundPrefs]),
          builder: (context, _) {
            final prefs =
                widget.controller.profile?.notificationPreferences ?? {};

            return ListView(
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
                const SizedBox(height: 10),
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: Column(
                    children: [
                      _buildToggleTile(
                        context: context,
                        title: 'Push Notifications',
                        subtitle: 'Heads-up alerts on your device screen',
                        keyName: 'push_enabled',
                        prefs: prefs,
                      ),
                      Divider(color: tokens.subtleBorder, height: 1),
                      _buildToggleTile(
                        context: context,
                        title: 'SMS Text Alerts',
                        subtitle:
                            'Verification codes and critical arrival updates',
                        keyName: 'sms_enabled',
                        prefs: prefs,
                      ),
                      Divider(color: tokens.subtleBorder, height: 1),
                      _buildToggleTile(
                        context: context,
                        title: 'Email Invoices & Statements',
                        subtitle:
                            'Digital VAT receipts and monthly expense reports',
                        keyName: 'email_enabled',
                        prefs: prefs,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Notification Categories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: Column(
                    children: [
                      _buildToggleTile(
                        context: context,
                        title: 'Urgent Dispatch & OTP Alerts',
                        subtitle:
                            'Audio chimes and real-time arrival countdowns',
                        keyName: 'urgent_alerts',
                        prefs: prefs,
                      ),
                      Divider(color: tokens.subtleBorder, height: 1),
                      _buildToggleTile(
                        context: context,
                        title: 'Birthday Reminders & Rewards',
                        subtitle: 'Special celebratory discounts and vouchers',
                        keyName: 'birthday_reminders',
                        prefs: prefs,
                      ),
                      Divider(color: tokens.subtleBorder, height: 1),
                      _buildToggleTile(
                        context: context,
                        title: 'Promotional Offers & Tips',
                        subtitle: 'Occasional seasonal maintenance deals',
                        keyName: 'promotional',
                        prefs: prefs,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Sound, Chime & Haptic Controls',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Dispatch Bell Chime',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Play custom SKAVIA sound on urgent alerts',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: soundPrefs.notificationSoundEnabled,
                        activeThumbColor: tokens.brandAccent,
                        onChanged: soundPrefs.setNotificationSound,
                      ),
                      Divider(color: tokens.subtleBorder, height: 1),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'In-App Message Tone',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Audio cue when receiving live chat replies',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: soundPrefs.messageSoundEnabled,
                        activeThumbColor: tokens.brandAccent,
                        onChanged: soundPrefs.setMessageSound,
                      ),
                      Divider(color: tokens.subtleBorder, height: 1),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Device Vibration',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Vibrate pattern for incoming bookings & OTPs',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: soundPrefs.vibrationEnabled,
                        activeThumbColor: tokens.brandAccent,
                        onChanged: soundPrefs.setVibrationEnabled,
                      ),
                      Divider(color: tokens.subtleBorder, height: 1),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Tactile Haptics',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Subtle haptic tap feedback for interactions',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: soundPrefs.hapticFeedbackEnabled,
                        activeThumbColor: tokens.brandAccent,
                        onChanged: soundPrefs.setHapticFeedback,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        await NotificationService.instance
                            .previewNotificationSound();
                        if (context.mounted) {
                          UiFeedbackHelper.showInfo(
                            context,
                            'Alert chime preview played.',
                          );
                        }
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.volume_up_rounded, size: 18),
                          SizedBox(width: 8),
                          Flexible(child: Text('Preview Chime')),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        final opened = await NotificationService.instance
                            .openAppSettingsPage();
                        if (!opened && context.mounted) {
                          UiFeedbackHelper.showInfo(
                            context,
                            'Open OS Settings -> Apps -> SKAVIA -> Notifications.',
                          );
                        }
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tune_rounded, size: 18),
                          SizedBox(width: 8),
                          Flexible(child: Text('Device Settings')),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String keyName,
    required Map<String, dynamic> prefs,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    final isEnabled = prefs[keyName] as bool? ?? true;

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
      ),
      value: isEnabled,
      activeThumbColor: tokens.brandAccent,
      onChanged: (val) {
        widget.controller.toggleNotificationPreference(keyName, val);
      },
    );
  }
}
