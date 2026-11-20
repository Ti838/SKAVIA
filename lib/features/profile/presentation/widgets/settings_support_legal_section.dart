import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../app_update/data/models/app_release_model.dart';
import '../../../app_update/providers/app_update_provider.dart';
import '../../../navigation/presentation/widgets/legal_policies_sheet.dart';

/// Support, Complaints, Legal Policies, and App Releases section for SettingsScreen.
class SettingsSupportLegalSection extends StatelessWidget {
  final VoidCallback onCallHelpline;

  const SettingsSupportLegalSection({super.key, required this.onCallHelpline});

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
          isBn ? 'সহায়তা ও আইনি তথ্য' : 'Support, Complaints & Legal',
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
                icon: Icons.help_outline_rounded,
                title: isBn
                    ? 'সহায়তা ও প্রশ্নোত্তর (FAQ)'
                    : 'Help Center & FAQ',
                subtitle: 'Escrow rules, OTP guide & quick answers',
                onTap: () => Navigator.pushNamed(context, AppRoutes.supportFaq),
              ),
              Divider(color: tokens.subtleBorder, height: 1),
              _navTile(
                context,
                icon: Icons.report_problem_outlined,
                title: isBn ? 'অভিযোগ জমা দিন' : 'File a Formal Complaint',
                subtitle: 'Report quality, delay, billing or conduct issues',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.submitComplaint),
              ),
              Divider(color: tokens.subtleBorder, height: 1),
              _navTile(
                context,
                icon: Icons.phone_in_talk_outlined,
                title: isBn ? '২৪/৭ হেল্পলাইন: ১৬৫২৪' : '24/7 Helpline: 16524',
                subtitle: 'Immediate dispatch and emergency assistance',
                onTap: onCallHelpline,
              ),
              Divider(color: tokens.subtleBorder, height: 1),
              _navTile(
                context,
                icon: Icons.policy_outlined,
                title: isBn
                    ? 'আইনি নীতিমালা ও ১৫% স্বচ্ছ ফি'
                    : 'Legal Policies & 15% Fee Schedule',
                subtitle: 'Terms, privacy & escrow protection rules',
                onTap: () => LegalPoliciesSheet.show(context),
              ),
              Divider(color: tokens.subtleBorder, height: 1),
              AnimatedBuilder(
                animation: AppUpdateProvider.instance,
                builder: (context, _) {
                  final eval = AppUpdateProvider.instance.evaluation;
                  final subtitle = eval == null
                      ? 'Check for official SKAVIA Android releases'
                      : eval.updateAvailable
                      ? 'Update ready: v${eval.latestRelease?.versionName} (${eval.latestRelease?.formattedSize ?? 'APK'})'
                      : eval.status == AppUpdateAvailability.upToDate
                      ? 'Up to date · v${eval.installedVersion}+${eval.installedBuild}'
                      : 'Version check & release verification';
                  return _navTile(
                    context,
                    icon: Icons.system_update_rounded,
                    title: isBn ? 'অ্যাপ আপডেট' : 'App Updates & Releases',
                    subtitle: subtitle,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.appUpdate),
                  );
                },
              ),
              Divider(color: tokens.subtleBorder, height: 1),
              _navTile(
                context,
                icon: Icons.monitor_heart_outlined,
                title: isBn
                    ? 'ডিভাইস ও সিস্টেম ডায়াগনস্টিকস'
                    : 'Device & Diagnostics',
                subtitle: isBn
                    ? 'হার্ডওয়্যার, প্রসেসর, নেটওয়ার্ক ও পারমিশন টেস্ট'
                    : 'Hardware, OS, network latency & permission audit',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.deviceDiagnostics),
              ),
              Divider(color: tokens.subtleBorder, height: 1),
              _navTile(
                context,
                icon: Icons.info_outline_rounded,
                title: isBn ? 'SKAVIA সম্পর্কে' : 'About SKAVIA',
                subtitle: 'App version, 9 specialization branches & mission',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.aboutSkavia),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
