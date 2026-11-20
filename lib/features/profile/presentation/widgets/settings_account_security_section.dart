import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_card.dart';
import '../controllers/profile_controller.dart';

/// Navigation section for Account & Security tiles in SettingsScreen.
class SettingsAccountSecuritySection extends StatelessWidget {
  final ProfileController profileController;

  const SettingsAccountSecuritySection({
    super.key,
    required this.profileController,
  });

  Widget _navTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    return ListTile(
      leading: Icon(icon, color: tokens.brandAccent),
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
        style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    final isBn = context.isBengali;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isBn ? 'অ্যাকাউন্ট ও নিরাপত্তা' : 'Account & Security',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _navTile(
                context,
                icon: Icons.person_outline_rounded,
                title: isBn ? 'ব্যক্তিগত তথ্য' : 'Personal Details',
                subtitle: 'Name, birthday, emergency contact & company',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.editDetailedProfile,
                  arguments: profileController,
                ),
              ),
              Divider(color: tokens.subtleBorder, height: 1),
              _navTile(
                context,
                icon: Icons.location_on_outlined,
                title: isBn ? 'সংরক্ষিত ঠিকানা' : 'Saved Addresses',
                subtitle: 'Home, office & default dispatch zones',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.savedAddresses,
                  arguments: profileController,
                ),
              ),
              Divider(color: tokens.subtleBorder, height: 1),
              _navTile(
                context,
                icon: Icons.notifications_active_outlined,
                title: isBn
                    ? 'নোটিফিকেশন ও শব্দ'
                    : 'Notifications, Chime & Haptics',
                subtitle: 'Channels, custom alert chime & vibration',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.notificationPreferences,
                  arguments: profileController,
                ),
              ),
              Divider(color: tokens.subtleBorder, height: 1),
              _navTile(
                context,
                icon: Icons.shield_outlined,
                title: isBn ? 'প্রাইভেসি ও নিরাপত্তা' : 'Privacy & Security',
                subtitle: 'Active devices, password reset & deactivation',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.privacySecurity,
                  arguments: profileController,
                ),
              ),
              Divider(color: tokens.subtleBorder, height: 1),
              _navTile(
                context,
                icon: Icons.receipt_long_outlined,
                title: isBn
                    ? 'লেনদেন ও ভ্যাট ইনভয়েস'
                    : 'Transaction History & Invoices',
                subtitle: 'Payment receipts and escrow settlements',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.transactionHistory,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
