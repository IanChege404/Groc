import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

class EnvConfig {
  static final EnvConfig _instance = EnvConfig._internal();

  factory EnvConfig() {
    return _instance;
  }

  EnvConfig._internal();

  /// Initialize the environment configuration
  /// Call this in main() before runApp()
  static Future<void> init({String envFile = '.env.development'}) async {
    try {
      await dotenv.load(fileName: envFile);
      Logger.info('Loaded environment from: $envFile', 'EnvConfig.init');
    } catch (e) {
      Logger.warning(
        'Could not load $envFile - using defaults. Error: $e',
        'EnvConfig.init',
      );
      // Continue with defaults if file not found
    }
  }

  /// Get the environment name (development, staging, production)
  static String appEnv() => dotenv.env['APP_ENV'] ?? 'development';

  /// Get the API base URL for the current environment
  static String apiBaseUrl() =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';

  /// Get API timeout in seconds
  static int apiTimeout() =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30') ?? 30;

  /// M-Pesa Configuration
  static String mpesaConsumerKey() => dotenv.env['MPESA_CONSUMER_KEY'] ?? '';

  static String mpesaConsumerSecret() =>
      dotenv.env['MPESA_CONSUMER_SECRET'] ?? '';

  static String mpesaPasskey() => dotenv.env['MPESA_PASSKEY'] ?? '';

  static String mpesaBusinessShortcode() =>
      dotenv.env['MPESA_BUSINESS_SHORTCODE'] ?? '174379';

  static String mpesaCallbackUrl() => dotenv.env['MPESA_CALLBACK_URL'] ?? '';

  /// Feature Flags
  static bool isPaymentGatewayEnabled() =>
      dotenv.env['ENABLE_PAYMENT_GATEWAY']?.toLowerCase() == 'true';

  static bool isAnalyticsEnabled() =>
      dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';

  static bool isDebugMode() =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';

  /// Check if running in production
  static bool isProduction() => appEnv() == 'production';

  /// Check if running in development
  static bool isDevelopment() => appEnv() == 'development';

  /// Check if running in staging
  static bool isStaging() => appEnv() == 'staging';

  /// Log all loaded environment variables (only in debug mode)
  static void printEnvVariables() {
    if (isDebugMode()) {
      Logger.debug('=== Environment Variables ===', 'EnvConfig');
      Logger.debug('APP_ENV: ${appEnv()}', 'EnvConfig');
      Logger.debug('API_BASE_URL: ${apiBaseUrl()}', 'EnvConfig');
      Logger.debug('API_TIMEOUT: ${apiTimeout()}s', 'EnvConfig');
      Logger.debug(
        'ENABLE_PAYMENT_GATEWAY: ${isPaymentGatewayEnabled()}',
        'EnvConfig',
      );
      Logger.debug('ENABLE_ANALYTICS: ${isAnalyticsEnabled()}', 'EnvConfig');
      Logger.debug('DEBUG_MODE: ${isDebugMode()}', 'EnvConfig');
      Logger.debug('=== End Variables ===', 'EnvConfig');
    }
  }
}
