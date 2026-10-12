import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';

void main() async {
  // Safe async initialization of Firebase Core, Auth, and Supabase PostgREST
  await AppBootstrap.init();

  // Launch root application
  runApp(const SkaviaApp());
}
