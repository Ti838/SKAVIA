import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../data/models/app_release_model.dart';
import '../../providers/app_update_provider.dart';
import '../widgets/app_update_status_cards.dart';

class AppUpdateScreen extends StatefulWidget {
  final AppUpdateProvider? provider;
  final bool blockingMode;

  const AppUpdateScreen({
    super.key,
    this.provider,
    this.blockingMode = false,
  });

  @override
  State<AppUpdateScreen> createState() => _AppUpdateScreenState();
}

class _AppUpdateScreenState extends State<AppUpdateScreen>
    with WidgetsBindingObserver {
  AppUpdateProvider get _provider =>
      widget.provider ?? AppUpdateProvider.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_provider.evaluation == null && !_provider.isBusy) {
        _provider.checkForUpdates(trigger: 'update_screen_open', force: true);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _provider.resumePendingInstallIfPermitted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;

    return AnimatedBuilder(
      animation: _provider,
      builder: (context, _) {
        final eval = _provider.evaluation;
        final release = eval?.latestRelease;
        final isBlocking =
            widget.blockingMode ||
            (eval?.requiresImmediateBlockingUpdate ?? false);

        return PopScope(
          canPop: !isBlocking,
          child: Scaffold(
            backgroundColor: tokens.sheetBg,
            appBar: AppAppBar(
              title: isBlocking ? 'Required Update' : 'App Updates',
              leading: isBlocking ? const SizedBox.shrink() : null,
              actions: [
                if (!isBlocking && !_provider.isBusy)
                  IconButton(
                    tooltip: 'Check Again',
                    onPressed: () => _provider.checkForUpdates(
                      trigger: 'manual_refresh',
                      force: true,
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
              ],
            ),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                children: [
                  AppUpdateSummaryCard(
                    evaluation: eval,
                    phase: _provider.phase,
                    isBlocking: isBlocking,
                  ),
                  const SizedBox(height: 16),

                  if (release != null) ...[
                    AppCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Available Release: v${release.versionName}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: tokens.brandAccent.withValues(
                                    alpha: 0.14,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Build #${release.buildNumber} · ${release.formattedSize}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.brandAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (release.releaseNotes.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              release.releaseNotes,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurfaceVariant,
                                height: 1.45,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.verified_user_outlined,
                                  size: 16,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'SHA-256: ${release.sha256Checksum.substring(0, 16)}…${release.sha256Checksum.substring(release.sha256Checksum.length - 8)}',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontFamily: 'monospace',
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildActionSection(context, eval!, release),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_provider.phase == AppUpdatePhase.error &&
                      _provider.errorMessage != null) ...[
                    AppCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.errorRed,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _provider.errorMessage!,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (eval != null &&
                      (eval.status == AppUpdateAvailability.networkUnavailable ||
                          eval.status == AppUpdateAvailability.unconfigured ||
                          eval.status == AppUpdateAvailability.invalidMetadata ||
                          eval.status == AppUpdateAvailability.upToDate ||
                          eval.status ==
                              AppUpdateAvailability.noPublishedRelease)) ...[
                    AppUpdateStatusInfoCard(
                      evaluation: eval,
                      isBusy: _provider.isBusy,
                      onRetry: () => _provider.checkForUpdates(
                        trigger: 'manual_retry',
                        force: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  AppUpdateSupportGuidanceCard(
                    supportInfo: eval?.supportInfo,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionSection(
    BuildContext context,
    AppUpdateEvaluation eval,
    AppReleaseInfo release,
  ) {
    final phase = _provider.phase;

    if (phase == AppUpdatePhase.downloading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Downloading Official APK...',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              Text(
                '${(_provider.progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _provider.progress > 0 ? _provider.progress : null,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${Formatters.formatFileSize(_provider.downloadedBytes)} / ${Formatters.formatFileSize(_provider.totalBytes)}',
            style: TextStyle(
              fontSize: 11.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _provider.cancelDownload,
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('Cancel Download'),
          ),
        ],
      );
    }

    if (phase == AppUpdatePhase.verifying) {
      return const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Verifying cryptographic SHA-256 checksum...',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
    }

    if (phase == AppUpdatePhase.awaitingInstallPermission) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.4),
              ),
            ),
            child: const Text(
              'APK downloaded & SHA-256 verified! Grant Android permission to "Install unknown apps" for SKAVIA, then return here to finish upgrading.',
              style: TextStyle(fontSize: 12.5, height: 1.35),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _provider.openInstallPermissionSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRoyal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.settings_outlined),
            label: const Text('Allow Install Permission in Settings'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _provider.resumePendingInstallIfPermitted,
            icon: const Icon(Icons.install_mobile_rounded),
            label: const Text('I Enabled Permission · Continue Install'),
          ),
        ],
      );
    }

    if (phase == AppUpdatePhase.installerOpened) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Android Package Installer opened. Tap "Update" in the Android prompt to apply this release.',
              style: TextStyle(fontSize: 12.5, height: 1.35),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _provider.startDownloadAndInstall,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Re-open Installer'),
          ),
        ],
      );
    }

    if (!eval.updateAvailable) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _provider.startDownloadAndInstall,
        style: ElevatedButton.styleFrom(
          backgroundColor: eval.requiresImmediateBlockingUpdate
              ? AppColors.errorRed
              : AppColors.primaryRoyal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.download_for_offline_rounded),
        label: Text(
          'Download & Verify Update (${release.formattedSize})',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
