import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/config/app_config.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../app_update/data/models/app_release_model.dart';
import '../../../app_update/providers/app_update_provider.dart';
import '../../../navigation/presentation/widgets/legal_policies_sheet.dart';

class AboutSkaviaScreen extends StatefulWidget {
  final AppUpdateProvider? updateProvider;

  const AboutSkaviaScreen({super.key, this.updateProvider});

  @override
  State<AboutSkaviaScreen> createState() => _AboutSkaviaScreenState();
}

class _AboutSkaviaScreenState extends State<AboutSkaviaScreen> {
  String _versionLabel = '${AppConfig.appVersion}+1';

  AppUpdateProvider get _updateProvider =>
      widget.updateProvider ?? AppUpdateProvider.instance;

  static const List<(String, String)> _branches = [
    ('TECH', 'SKAVIA Technical'),
    ('HOME', 'SKAVIA Home'),
    ('CORP', 'SKAVIA Corporate'),
    ('AGRI', 'SKAVIA Agriculture'),
    ('LOGI', 'SKAVIA Logistics'),
    ('DIGI', 'SKAVIA Digital'),
    ('BIZ', 'SKAVIA Business'),
    ('CONS', 'SKAVIA Construction'),
    ('EVNT', 'SKAVIA Events'),
  ];

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted && info.version.isNotEmpty) {
        setState(() => _versionLabel = '${info.version}+${info.buildNumber}');
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;

    return Scaffold(
      appBar: const AppAppBar(title: 'About SKAVIA'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          children: [
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Image.asset(
                    AppAssets.emblem,
                    height: 64,
                    width: 64,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: tokens.softBlueBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.engineering_rounded,
                        size: 36,
                        color: tokens.brandAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'SKAVIA',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: tokens.brandAccent,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Every Skill. Every Opportunity.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySky.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Version $_versionLabel',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: tokens.brandAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  AnimatedBuilder(
                    animation: _updateProvider,
                    builder: (context, _) {
                      final eval = _updateProvider.evaluation;
                      final isChecking =
                          _updateProvider.phase == AppUpdatePhase.checking;
                      final hasUpdate = eval?.updateAvailable ?? false;
                      final statusText = isChecking
                          ? 'Checking SKAVIA release channel...'
                          : eval == null
                              ? 'Tap below to verify latest official release'
                              : eval.updateAvailable
                                  ? 'Update Available: v${eval.latestRelease?.versionName} (Build #${eval.latestRelease?.buildNumber})'
                                  : eval.status == AppUpdateAvailability.upToDate
                                      ? 'You are on the latest verified build'
                                      : eval.status ==
                                              AppUpdateAvailability.unconfigured
                                          ? 'Manual distribution mode'
                                          : 'Check update status & release notes';

                      return Column(
                        children: [
                          Text(
                            statusText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: hasUpdate
                                  ? AppColors.primaryRoyal
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: isChecking
                                    ? null
                                    : () => _updateProvider.checkForUpdates(
                                          trigger: 'about_screen',
                                          force: true,
                                        ),
                                icon: isChecking
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.sync_rounded, size: 16),
                                label: Text(
                                  isChecking
                                      ? 'Checking...'
                                      : 'Check for Updates',
                                ),
                              ),
                              if (hasUpdate)
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.of(context)
                                      .pushNamed(AppRoutes.appUpdate),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryRoyal,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(
                                    Icons.system_update_rounded,
                                    size: 16,
                                  ),
                                  label: const Text('Update Now'),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Text(
              'Unified Solution Platform',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'SKAVIA operates as one managed service and workforce execution platform coordinating requirement capture, specialist matching, Team Leader project management, Job OTP escrow settlement, and verified reputation across 9 internal specialization branches.',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              '9 Specialization Branches',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _branches
                  .map(
                    (b) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.45,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: tokens.subtleBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            b.$1,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: tokens.brandAccent,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              b.$2,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),

            OutlinedButton(
              onPressed: () => LegalPoliciesSheet.show(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.gavel_rounded, size: 18),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text('Terms, Privacy & 15% Fee Schedule'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
