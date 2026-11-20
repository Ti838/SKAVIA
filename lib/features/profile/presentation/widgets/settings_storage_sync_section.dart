import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/network/offline_sync_queue_manager.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_card.dart';

/// Offline Sync and Local Cache management section for SettingsScreen.
class SettingsStorageSyncSection extends StatelessWidget {
  final bool isSyncing;
  final VoidCallback onSyncNow;
  final VoidCallback onClearCache;

  const SettingsStorageSyncSection({
    super.key,
    required this.isSyncing,
    required this.onSyncNow,
    required this.onClearCache,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isBn = context.isBengali;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isBn ? 'অফলাইন সিঙ্ক ও স্টোরেজ' : 'Offline Sync & Storage',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<int>(
          stream: OfflineSyncQueueManager.instance.pendingCountStream,
          initialData: OfflineSyncQueueManager.instance.pendingCount,
          builder: (context, snapshot) {
            final pending = snapshot.data ?? 0;
            final cachedItems = LocalCacheService.instance.count;
            return AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn
                        ? '${Formatters.toBengaliDigits(pending.toString())}টি অফলাইন কার্যক্রম • ${Formatters.toBengaliDigits(cachedItems.toString())}টি ক্যাশ রেকর্ড'
                        : '$pending pending offline item(s) • $cachedItems cached record(s)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: isSyncing ? null : onSyncNow,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            isSyncing
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.sync_rounded,
                                    size: 16,
                                  ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                isSyncing
                                    ? (isBn ? 'সিঙ্ক হচ্ছে...' : 'Syncing...')
                                    : (isBn ? 'এখনই সিঙ্ক করুন' : 'Sync Now'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: onClearCache,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cleaning_services_outlined,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                isBn ? 'ক্যাশ মুছুন' : 'Clear Cache',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
