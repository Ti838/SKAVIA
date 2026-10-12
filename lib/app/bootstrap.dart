import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../firebase_options.dart';
import 'config/app_config.dart';

/// Centralized async bootstrapper for SKAVIA.
/// Initializes Firebase Core, Firebase Auth, and Supabase PostgREST client.
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
  }
}
