import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/network/network_connectivity_service.dart';
import '../core/network/offline_sync_queue_manager.dart';
import '../core/services/notification_service.dart';
import '../features/notifications/presentation/controllers/notification_center_controller.dart';
import '../firebase_options.dart';
import 'config/app_config.dart';

/// Centralized async bootstrapper for SKAVIA.
/// Initializes Firebase Core, Firebase Auth, Supabase PostgREST client,
/// Real-Time Notification & Audio Chime channels, and Offline Sync Engine.
abstract class AppBootstrap {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Initialize Firebase Core
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('[Firebase Init] Notice: $e');
    }

    // 2. Initialize Supabase PostgREST & Auth Client
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('[Supabase Init] Error: $e');
    }

    // 3. Initialize Notification Channels & Audio Sound Driver
    try {
      await NotificationService.instance.initialize();
      NotificationCenterController.instance.initialize('current_user');
    } catch (e) {
      debugPrint('[NotificationService Init] Error: $e');
    }

    // 4. Initialize Network Monitoring & Offline Sync Engine
    try {
      NetworkConnectivityService.instance.startMonitoring();
      OfflineSyncQueueManager.instance.initialize();
    } catch (e) {
      debugPrint('[Offline Sync Init] Error: $e');
    }
  }
}
