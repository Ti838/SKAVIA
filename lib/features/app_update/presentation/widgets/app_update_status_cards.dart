import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../data/models/app_release_model.dart';
import '../../providers/app_update_provider.dart';

class AppUpdateSummaryCard extends StatelessWidget {
  final AppUpdateEvaluation? evaluation;
  final AppUpdatePhase phase;
  final bool isBlocking;

  const AppUpdateSummaryCard({
    super.key,
    required this.evaluation,
    required this.phase,
    required this.isBlocking,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    final eval = evaluation;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isBlocking ? AppColors.errorRed : tokens.brandAccent)
                      .withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isBlocking
                      ? Icons.security_update_warning_rounded
                      : Icons.system_update_rounded,
                  color: isBlocking ? AppColors.errorRed : tokens.brandAccent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _headlineFor(eval, phase),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      eval != null
                          ? 'Installed: v${eval.installedVersion} (Build #${eval.installedBuild})'
                          : 'Checking installed SKAVIA version...',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isBlocking && eval != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.errorRed.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                eval.status == AppUpdateAvailability.unsupportedInstalledBuild
                    ? 'Build #${eval.installedBuild} is no longer supported. Updating preserves your account, bookings, and data seamlessly.'
                    : eval.installedBuildSuspended &&
                            eval.installedSuspensionReason != null
                        ? eval.installedSuspensionReason!
                        : 'This critical release is required before continuing.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _headlineFor(AppUpdateEvaluation? eval, AppUpdatePhase phase) {
    if (phase == AppUpdatePhase.checking) return 'Checking for Updates...';
    if (eval == null) return 'SKAVIA App Updates';
    return switch (eval.status) {
      AppUpdateAvailability.upToDate => 'SKAVIA Is Up to Date',
      AppUpdateAvailability.noPublishedRelease => 'No Pending Update',
      AppUpdateAvailability.optionalUpdate => 'New Update Available',
      AppUpdateAvailability.mandatoryUpdate => 'Mandatory Update Required',
      AppUpdateAvailability.unsupportedInstalledBuild =>
        'App Version Unsupported',
      AppUpdateAvailability.suspendedInstalledBuild =>
        'Current Release Suspended',
      AppUpdateAvailability.networkUnavailable => 'Update Check Offline',
      AppUpdateAvailability.unconfigured => 'Manual Website Check',
      AppUpdateAvailability.invalidMetadata => 'Invalid Update Metadata',
    };
  }
}

class AppUpdateStatusInfoCard extends StatelessWidget {
  final AppUpdateEvaluation evaluation;
  final bool isBusy;
  final VoidCallback onRetry;

  const AppUpdateStatusInfoCard({
    super.key,
    required this.evaluation,
    required this.isBusy,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _statusSubtitle(evaluation),
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          if (evaluation.status == AppUpdateAvailability.networkUnavailable &&
              !isBusy) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry Connection'),
            ),
          ],
        ],
      ),
    );
  }

  static String _statusSubtitle(AppUpdateEvaluation eval) {
    return switch (eval.status) {
      AppUpdateAvailability.upToDate =>
        'You are running the latest verified SKAVIA Android build.',
      AppUpdateAvailability.noPublishedRelease =>
        'No newer Android release has been published on your release channel yet.',
      AppUpdateAvailability.networkUnavailable =>
        eval.errorMessage ??
            'Could not reach SKAVIA release servers right now. You can continue using the app normally and retry when online.',
      AppUpdateAvailability.unconfigured =>
        'This development build does not define SKAVIA_WEB_ORIGIN. Pass --dart-define=SKAVIA_WEB_ORIGIN=<url> when building, or download updates directly from the official SKAVIA website.',
      AppUpdateAvailability.invalidMetadata =>
        eval.errorMessage ??
            'Server returned incomplete or invalid release metadata. Safety checks aborted this update prompt.',
      _ => '',
    };
  }
}

class AppUpdateSupportGuidanceCard extends StatelessWidget {
  final AppUpdateSupportInfo? supportInfo;

  const AppUpdateSupportGuidanceCard({super.key, this.supportInfo});

  Future<void> _launchSupportCall(String helpline) async {
    final uri = Uri(scheme: 'tel', path: helpline);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchSupportEmail(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'SKAVIA App Update Assistance'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWebsiteDownload(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.scheme == 'https' || uri.scheme == 'http')) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final helpline = supportInfo?.helpline ?? '16524';
    final email = supportInfo?.supportEmail ?? 'support@skavia.com';
    final websiteUrl = supportInfo?.websiteDownloadUrl;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Install Guidance & Emergency Support',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '1. Tap Download & Verify to save the official APK into protected app storage.\n'
            '2. If Android asks for permission once, enable "Allow from this source" for SKAVIA.\n'
            '3. Confirm Update in the Android installer — your account and session stay signed in.',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _launchSupportCall(helpline),
                icon: const Icon(Icons.phone_in_talk_outlined, size: 16),
                label: Text('Helpline $helpline'),
              ),
              OutlinedButton.icon(
                onPressed: () => _launchSupportEmail(email),
                icon: const Icon(Icons.email_outlined, size: 16),
                label: const Text('Support Email'),
              ),
              if (websiteUrl != null && websiteUrl.startsWith('http'))
                OutlinedButton.icon(
                  onPressed: () => _openWebsiteDownload(websiteUrl),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Open Website Download'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

