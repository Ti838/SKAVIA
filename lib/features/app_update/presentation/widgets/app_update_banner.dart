import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../data/models/app_release_model.dart';
import '../../providers/app_update_provider.dart';

class AppUpdateBanner extends StatelessWidget {
  final AppUpdateProvider? provider;

  const AppUpdateBanner({super.key, this.provider});

  @override
  Widget build(BuildContext context) {
    final updateProvider = provider ?? AppUpdateProvider.instance;

    return AnimatedBuilder(
      animation: updateProvider,
      builder: (context, _) {
        if (!updateProvider.shouldShowDeferredBanner) {
          return const SizedBox.shrink();
        }
        final eval = updateProvider.evaluation;
        if (eval == null) return const SizedBox.shrink();
        final isSuspended =
            eval.status == AppUpdateAvailability.suspendedInstalledBuild;
        final release = eval.latestRelease;
        final tokens = context.skavia;
        final accent = isSuspended ? AppColors.warning : tokens.brandAccent;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Material(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.appUpdate),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSuspended
                          ? Icons.warning_amber_rounded
                          : Icons.system_update_rounded,
                      size: 18,
                      color: accent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isSuspended
                            ? 'Installed build #${eval.installedBuild} was suspended. Tap for update options.'
                            : 'SKAVIA v${release?.versionName ?? ''} ready (${release?.formattedSize ?? 'APK'})',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Update',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

