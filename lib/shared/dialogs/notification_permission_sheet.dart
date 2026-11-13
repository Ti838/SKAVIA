import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/theme/app_colors.dart';
import '../../core/services/notification_service.dart';

/// Polite In-App Notification Permission Sheet (Industry standard pre-prompt).
///
/// Educates the user on why notifications and sound alerts are needed before
/// invoking the operating system's native permission dialog.
class NotificationPermissionSheet extends StatefulWidget {
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onDismissed;

  const NotificationPermissionSheet({
    super.key,
    this.onPermissionGranted,
    this.onDismissed,
  });

  /// Static helper to present the sheet modally.
  static Future<bool> show(BuildContext context) async {
    final status = await NotificationService.instance.checkPermissionStatus();
    if (status.isGranted) return true;

    if (!context.mounted) return false;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NotificationPermissionSheet(),
    );

    return result ?? false;
  }

  @override
  State<NotificationPermissionSheet> createState() =>
      _NotificationPermissionSheetState();
}

class _NotificationPermissionSheetState
    extends State<NotificationPermissionSheet> {
  bool _isLoading = false;
  bool _isPermanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final status = await NotificationService.instance.checkPermissionStatus();
    if (mounted) {
      setState(() {
        _isPermanentlyDenied = status.isPermanentlyDenied;
      });
    }
  }

  Future<void> _handlePermissionAction() async {
    setState(() => _isLoading = true);

    if (_isPermanentlyDenied) {
      await NotificationService.instance.openAppSettingsPage();
      setState(() => _isLoading = false);
      if (mounted) Navigator.of(context).pop(false);
      return;
    }

    final granted =
        await NotificationService.instance.requestNotificationPermission();

    if (mounted) {
      setState(() => _isLoading = false);
      if (granted) {
        // Play sample audio confirmation chime
        await NotificationService.instance.playInAppNotificationSound();
        widget.onPermissionGranted?.call();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        await _checkStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = colorScheme.surface;
    final heroCircleBg = tokens
        ? AppColors.primarySky.withValues(alpha: 0.16)
        : AppColors.cardBlueTint;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Drag handle
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Visual Hero Icon with Sound Waves
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: heroCircleBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primarySky.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications_active_rounded,
                    size: 42,
                    color: AppColors.primarySky,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Text(
                'Stay Updated in Real Time',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                'Enable notifications to receive urgent job offers, real-time bids, and instant customer messages.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Benefit feature list
              _buildFeatureRow(
                context: context,
                icon: Icons.bolt_rounded,
                iconColor: AppColors.warning,
                title: 'Instant Job Bids & Match Alerts',
                description:
                    'Get notified immediately with custom sound when new tasks match your skill.',
              ),
              const SizedBox(height: 14),
              _buildFeatureRow(
                context: context,
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: AppColors.primarySky,
                title: 'Direct Client & Worker Chat',
                description:
                    'Never miss an update or message during an ongoing project.',
              ),
              const SizedBox(height: 14),
              _buildFeatureRow(
                context: context,
                icon: Icons.security_rounded,
                iconColor: AppColors.success,
                title: 'Secure OTPs & Completion Alerts',
                description:
                    'Receive time-sensitive job verification pins securely.',
              ),
              const SizedBox(height: 28),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePermissionAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primarySky,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isPermanentlyDenied
                              ? 'Open App Settings'
                              : 'Turn on Sound & Alerts',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Skip / Maybe Later button
              TextButton(
                onPressed: () {
                  widget.onDismissed?.call();
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  'Maybe Later',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

