/// Application environment configuration
class AppConfig {
  AppConfig._();

  static const String appName = 'SKAVIA';
  static const String appVersion = '1.0.0';

  // Official SKAVIA Web & Release Distribution API Origin (e.g. your Vercel deployment)
  // Inject via --dart-define=SKAVIA_WEB_ORIGIN=https://your-project.vercel.app (never trailing slash).
  // Never hardcode APK download URLs directly inside the app.
  static const String releaseApiBaseUrl = String.fromEnvironment(
    'SKAVIA_WEB_ORIGIN',
    defaultValue: '',
  );
  static const String releaseChannel = String.fromEnvironment(
    'SKAVIA_RELEASE_CHANNEL',
    defaultValue: 'stable',
  );

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

  // SSLCommerz Payment Gateway Configuration
  // Inject strictly via compile-time --dart-define for sandbox or live credentials.
  static const String sslCommerzStoreId = String.fromEnvironment(
    'SSLCOMMERZ_STORE_ID',
    defaultValue: '',
  );
  static const String sslCommerzStorePasswd = String.fromEnvironment(
    'SSLCOMMERZ_STORE_PASSWD',
    defaultValue: '',
  );
  static const bool sslCommerzIsSandbox = bool.fromEnvironment(
    'SSLCOMMERZ_IS_SANDBOX',
    defaultValue: true,
  );
  static const String sslCommerzIpnUrlOverride = String.fromEnvironment(
    'SSLCOMMERZ_IPN_URL',
    defaultValue: '',
  );
  static String get sslCommerzIpnUrl => sslCommerzIpnUrlOverride.isNotEmpty
      ? sslCommerzIpnUrlOverride
      : '$supabaseUrl/functions/v1/verify-sslcommerz-ipn';

  // Platform Business Model Configuration (SRS Section 3.1.O: Transparent SKAVIA Fee)
  static const double skaviaPlatformFeePercent =
      0.15; // 15% platform management fee

  // SKAVIA AI Engine Configuration (Groq & OpenRouter)
  // Injected strictly via compile-time --dart-define or managed securely via Supabase Edge Functions.
  // Never hardcode active production secret tokens into client application binaries.
  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );
  static const String openRouterApiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );
  static const String huggingFaceToken = String.fromEnvironment(
    'HUGGINGFACE_TOKEN',
    defaultValue: '',
  );
}
