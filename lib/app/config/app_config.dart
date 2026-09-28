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

  // SSLCommerz Payment Gateway Configuration (Defaults to free developer Sandbox)
  static const String sslCommerzStoreId = String.fromEnvironment(
    'SSLCOMMERZ_STORE_ID',
    defaultValue: 'testbox',
  );
  static const String sslCommerzStorePasswd = String.fromEnvironment(
    'SSLCOMMERZ_STORE_PASSWD',
    defaultValue: 'qwerty',
  );
  static const bool sslCommerzIsSandbox = bool.fromEnvironment(
    'SSLCOMMERZ_IS_SANDBOX',
    defaultValue: true,
  );

  // Platform Business Model Configuration (SRS Section 3.1.O: Transparent SKAVIA Fee)
  static const double skaviaPlatformFeePercent = 0.15; // 15% platform management fee
}

