import 'package:supabase_flutter/supabase_flutter.dart';

/// Safely returns [Supabase.instance.client] when initialized, or `null` in
/// offline/headless unit tests where `Supabase.initialize` has not been called.
///
/// Checking `Supabase.instance.isInitialized` directly throws an `AssertionError`
/// when uninitialized because the `Supabase.instance` getter itself asserts
/// initialization, so any probe must live inside a `try` block.
SupabaseClient? tryGetSupabaseClient() {
  try {
    final instance = Supabase.instance;
    if (!instance.isInitialized) return null;
    return instance.client;
  } catch (_) {
    return null;
  }
}

