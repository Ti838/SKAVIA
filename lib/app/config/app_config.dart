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
    defaultValue: 'sb_publishable_pdNZXWOsIM757lVSYOjwdw_LTk6aCDN',
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
  static const double skaviaPlatformFeePercent =
      0.15; // 15% platform management fee

  // SKAVIA AI Engine Configuration (Groq & OpenRouter)
  // Securely injected via compile-time --dart-define with active production fallbacks
  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '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',
  );
  static const String openRouterApiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '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',
  );
  static const String huggingFaceToken = String.fromEnvironment(
    'HUGGINGFACE_TOKEN',
    defaultValue: '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',
  );
}
