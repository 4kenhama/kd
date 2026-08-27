/// KD Network Configuration
/// Centralized backend URLs and API constants for KD app
/// Supports development, staging, and production environments

class KDNetworkConfig {
  /// Development backend URL (local XAMPP/Docker)
  static const String localBackendUrl = 'http://10.0.2.2:3000';

  /// Production backend URL
  static const String productionBackendUrl = 'https://api.kd-app.com';

  /// Staging backend URL
  static const String stagingBackendUrl = 'https://staging-api.kd-app.com';

  /// Current active backend URL (defaults to production)
  static String activeBackendUrl = productionBackendUrl;

  /// Switch to development environment
  static void useDevelopment() {
    activeBackendUrl = localBackendUrl;
  }

  /// Switch to staging environment
  static void useStaging() {
    activeBackendUrl = stagingBackendUrl;
  }

  /// Switch to production environment
  static void useProduction() {
    activeBackendUrl = productionBackendUrl;
  }

  /// API Endpoints
  static const String listingsEndpoint = '/api/listings';
  static const String profilesEndpoint = '/api/profiles';
  static const String messagesEndpoint = '/api/messages';
  static const String authEndpoint = '/api/auth';
  static const String uploadEndpoint = '/api/upload';

  /// Get full URL for endpoint
  static String getFullUrl(String endpoint) {
    return '$activeBackendUrl$endpoint';
  }
}
