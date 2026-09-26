/// Application environment configuration
class AppConfig {
  AppConfig._();

  static const String appName = 'SKAVIA';
  static const String appVersion = '1.0.0';

  // Supabase Configuration (Injected via compile-time --dart-define or .env)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://mfsrvtvgjrwrwapkmlxg.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  // Network timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
