import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/network/network_connectivity_service.dart';
import '../core/network/offline_sync_queue_manager.dart';
import '../core/network/offline_sync_replay_handler.dart';
import '../core/services/app_language_service.dart';
import '../core/services/app_theme_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/sound_haptic_preferences.dart';
import '../core/storage/local_cache_service.dart';
import '../core/storage/secure_storage_service.dart';
import '../features/app_update/providers/app_update_provider.dart';
import '../features/notifications/presentation/controllers/notification_center_controller.dart';
import '../firebase_options.dart';
import 'app.dart';
import 'config/app_config.dart';
import 'router/app_routes.dart';

/// Centralized async bootstrapper for SKAVIA.
/// Runs independent storage, preference, Firebase Core, and Supabase initializers
/// concurrently to minimize cold-start time, then wires auth-scoped notifications
/// and offline sync replay.
abstract class AppBootstrap {
  static Future<void> _guard(String label, Future<void> Function() task) async {
    try {
      await task();
    } catch (e) {
      debugPrint('[$label] Notice: $e');
    }
  }

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Hydrate local preferences/cache & initialize Firebase + Supabase concurrently
    await Future.wait([
      _guard('LocalCache Init', LocalCacheService.instance.init),
      _guard('SecureStorage Init', () => SecureStorageService().init()),
      _guard('Theme Init', AppThemeService.init),
      _guard('Language Init', AppLanguageService.init),
      _guard('SoundPrefs Init', SoundHapticPreferences.instance.init),
      _guard(
        'Firebase Init',
        () => Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
      ),
      _guard(
        'Supabase Init',
        () => Supabase.initialize(
          url: AppConfig.supabaseUrl,
          publishableKey: AppConfig.supabaseAnonKey,
        ),
      ),
    ]);

    // 2. Initialize Notification Channels & Auth-Scoped Inbox (audio player deferred lazily)
    await _guard('NotificationService Init', () async {
      await NotificationService.instance.initialize();
      NotificationService.instance.onNotificationTapped.listen((payload) {
        if (payload == AppRoutes.appUpdate) {
          SkaviaApp.rootNavigatorKey.currentState?.pushNamed(
            AppRoutes.appUpdate,
          );
        }
      });

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        NotificationCenterController.instance.initialize(currentUser.uid);
      }
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) {
          NotificationCenterController.instance.initialize(user.uid);
          unawaited(
            AppUpdateProvider.instance
                .checkForUpdates(trigger: 'session_restore')
                .then<void>((_) {}, onError: (_, _) {}),
          );
        } else {
          NotificationCenterController.instance.clearSession();
        }
      });
    });

    // 3. Initialize Network Monitoring & Offline Sync Engine with Live Replay
    try {
      NetworkConnectivityService.instance.startMonitoring();
      OfflineSyncQueueManager.instance.registerBackendHandler(
        OfflineSyncReplayHandler.replay,
      );
      OfflineSyncQueueManager.instance.initialize();
    } catch (e) {
      debugPrint('[Offline Sync Init] Error: $e');
    }
  }
}
