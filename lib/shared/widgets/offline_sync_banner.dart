import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/network/network_connectivity_service.dart';
import '../../core/network/offline_sync_queue_manager.dart';

/// Interactive top banner displaying connectivity state and offline synchronization status.
class OfflineSyncBanner extends StatelessWidget {
  const OfflineSyncBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NetworkQualityState>(
      stream: NetworkConnectivityService.instance.stateStream,
      initialData: NetworkConnectivityService.instance.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? NetworkQualityState.online;

        if (state == NetworkQualityState.online) {
          return const SizedBox.shrink();
        }

        Color bgColor;
        IconData icon;
        String message;

        switch (state) {
          case NetworkQualityState.poorNetwork:
            bgColor = AppColors.warning;
            icon = Icons.network_check_rounded;
            message = 'Slow connection detected — offline drafts active';
            break;
          case NetworkQualityState.offline:
            final count = OfflineSyncQueueManager.instance.pendingCount;
            bgColor = Colors.blueGrey.shade800;
            icon = Icons.cloud_off_rounded;
            message = count > 0
                ? 'Offline mode — $count change${count > 1 ? 's' : ''} queued for sync'
                : 'You are currently offline';
            break;
          case NetworkQualityState.syncing:
            bgColor = AppColors.primaryRoyal;
            icon = Icons.sync_rounded;
            message = 'Syncing offline changes with cloud...';
            break;
          case NetworkQualityState.syncFailed:
            bgColor = AppColors.errorRed;
            icon = Icons.sync_problem_rounded;
            message = 'Sync failed — tap to retry';
            break;
          case NetworkQualityState.online:
            return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: bgColor,
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (state == NetworkQualityState.syncFailed)
                GestureDetector(
                  onTap: () => OfflineSyncQueueManager.instance.processQueue(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'RETRY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

