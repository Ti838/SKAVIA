import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../data/models/app_release_model.dart';
import '../../providers/app_update_provider.dart';

class AppUpdateDialog extends StatelessWidget {
  final AppUpdateEvaluation evaluation;
  final VoidCallback onUpdateNow;
  final VoidCallback? onLater;

  const AppUpdateDialog({
    super.key,
    required this.evaluation,
    required this.onUpdateNow,
    this.onLater,
  });

  static Future<void> show(
    BuildContext context, {
    required AppUpdateEvaluation evaluation,
    AppUpdateProvider? provider,
  }) async {
    final updateProvider = provider ?? AppUpdateProvider.instance;
    if (evaluation.requiresImmediateBlockingUpdate) {
      Navigator.of(context).pushNamed(
        AppRoutes.appUpdate,
        arguments: {'blocking': true},
      );
      return;
    }

    updateProvider.markDialogPresented();
    await showDialog<void>(
      context: context,
      barrierDismissible: !evaluation.requiresImmediateBlockingUpdate,
      builder: (dialogCtx) => AppUpdateDialog(
        evaluation: evaluation,
        onUpdateNow: () {
          Navigator.of(dialogCtx).pop();
          Navigator.of(context).pushNamed(AppRoutes.appUpdate);
        },
        onLater: evaluation.requiresImmediateBlockingUpdate
            ? null
            : () {
                updateProvider.deferOptionalUpdate();
                Navigator.of(dialogCtx).pop();
              },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    final release = evaluation.latestRelease;
    final isMandatory = evaluation.requiresImmediateBlockingUpdate;

    return PopScope(
      canPop: !isMandatory,
      child: AlertDialog(
        backgroundColor: tokens.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isMandatory
                        ? AppColors.errorRed
                        : tokens.brandAccent)
                    .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isMandatory
                    ? Icons.security_update_warning_rounded
                    : Icons.system_update_rounded,
                color: isMandatory ? AppColors.errorRed : tokens.brandAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMandatory ? 'Required App Update' : 'SKAVIA Update Ready',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (release != null)
                    Text(
                      'v${evaluation.installedVersion} → v${release.versionName} · ${release.formattedSize}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMandatory) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.errorRed.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    evaluation.status ==
                            AppUpdateAvailability.unsupportedInstalledBuild
                        ? 'Your installed build (#${evaluation.installedBuild}) is below the minimum supported version. Update now to preserve booking, payment, and security compatibility.'
                        : 'This release includes critical compatibility and security fixes required to continue using SKAVIA safely.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
              if (release != null && release.releaseNotes.isNotEmpty) ...[
                Text(
                  'What\'s New',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  release.releaseNotes,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 15,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Verified official APK · SHA-256 integrity checked before install',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          if (!isMandatory && onLater != null)
            TextButton(
              onPressed: onLater,
              child: const Text('Later'),
            ),
          ElevatedButton.icon(
            onPressed: onUpdateNow,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isMandatory ? AppColors.errorRed : AppColors.primaryRoyal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Update Now'),
          ),
        ],
      ),
    );
  }
}

