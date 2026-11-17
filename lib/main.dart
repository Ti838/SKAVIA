import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';

void main() async {
  // Configures HTML5 clean path URL strategy (removes '#' hash for web)
  usePathUrlStrategy();

  // Safe async initialization of Firebase Core, Auth, and Supabase PostgREST
  await AppBootstrap.init();

  // Launch root application
  runApp(const SkaviaApp());
}
