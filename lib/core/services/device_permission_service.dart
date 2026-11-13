import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/theme/app_colors.dart';
import '../extensions/context_extensions.dart';

class DevicePermissionService {
  /// Request Camera Permission with user rationale dialog.
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;

    if (context.mounted) {
      final proceed = await _showRationaleDialog(
        context: context,
        title: 'Camera Access Required',
        description:
            'SKAVIA needs camera access so you can take clear photos of your broken appliances or plumbing fixtures. This helps technicians diagnose the exact issue before arriving.',
        icon: Icons.camera_alt_outlined,
      );
      if (!proceed) return false;
    }

    final newStatus = await Permission.camera.request();
    if (newStatus.isPermanentlyDenied && context.mounted) {
      _showSettingsRedirectDialog(context, 'Camera');
      return false;
    }

    return newStatus.isGranted;
  }

  /// Request Location Permission for proximity matching and doorstep dispatch.
  static Future<bool> requestLocationPermission(BuildContext context) async {
    final status = await Permission.locationWhenInUse.status;
    if (status.isGranted) return true;

    if (context.mounted) {
      final proceed = await _showRationaleDialog(
        context: context,
        title: 'Location Access Required',
        description:
            'SKAVIA uses your location to discover the closest verified trade specialists in your area and calculate accurate dispatch arrival times.',
        icon: Icons.location_on_outlined,
      );
      if (!proceed) return false;
    }

    final newStatus = await Permission.locationWhenInUse.request();
    if (newStatus.isPermanentlyDenied && context.mounted) {
      _showSettingsRedirectDialog(context, 'Location');
      return false;
    }

    return newStatus.isGranted;
  }

  /// Request Notification Permission for job alerts, OTPs, and messages.
  static Future<bool> requestNotificationPermission(
    BuildContext context,
  ) async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;

    final newStatus = await Permission.notification.request();
    return newStatus.isGranted;
  }

  static Future<bool> _showRationaleDialog({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: Icon(icon, color: ctx.skavia.brandAccent, size: 36),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
          description,
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRoyal,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Allow Access'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static void _showSettingsRedirectDialog(
    BuildContext context,
    String permissionName,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('$permissionName Permission Disabled'),
        content: Text(
          '$permissionName access is permanently denied. Please enable it in your phone settings to use this feature.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRoyal,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
