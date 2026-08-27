/// KD Security Gate Service
/// Handles app version checking, forced updates, and contact data masking
/// If the app is out of date, locks the viewport with an update screen

class KDSecurityGate {
  // Hardcoded version constants for MVP
  static const String currentVersion = '1.0.0';
  static const String minRequiredVersion = '1.0.0';

  // Global app state
  static bool _isLoggedIn = false;
  static bool _updateRequired = false;

  /// Check if user is logged in
  static bool get isLoggedIn => _isLoggedIn;

  /// Check if app update is required
  static bool get isUpdateRequired => _updateRequired;

  /// Initialize security gate on app startup
  static void initialize() {
    _checkVersionRequirement();
    // By default, user starts logged out
    _isLoggedIn = false;
  }

  /// Check if current version meets minimum requirement
  static void _checkVersionRequirement() {
    _updateRequired = !_isVersionValid(currentVersion, minRequiredVersion);
  }

  /// Compare semantic versions (e.g., "1.0.0")
  /// Returns true if current >= required
  static bool _isVersionValid(String current, String required) {
    try {
      final currentParts = current
          .split('.')
          .map(int.parse)
          .toList(); // [1, 0, 0]
      final requiredParts = required
          .split('.')
          .map(int.parse)
          .toList(); // [1, 0, 0]

      // Pad arrays to same length
      while (currentParts.length < requiredParts.length) {
        currentParts.add(0);
      }
      while (requiredParts.length < currentParts.length) {
        requiredParts.add(0);
      }

      // Compare each part (major, minor, patch)
      for (int i = 0; i < currentParts.length; i++) {
        if (currentParts[i] > requiredParts[i]) return true;
        if (currentParts[i] < requiredParts[i]) return false;
      }

      return true; // Versions are equal
    } catch (e) {
      // If parsing fails, assume valid to not break the app
      return true;
    }
  }

  /// Mock login for MVP
  /// In production, this would call Firebase/Supabase
  static void performMockLogin() {
    _isLoggedIn = true;
  }

  /// Mock logout
  static void performLogout() {
    _isLoggedIn = false;
  }

  /// Mask phone number when user is not logged in
  /// Shows: XXXXXXXXX
  static String maskPhoneNumber(String phone) {
    if (_isLoggedIn) {
      return phone; // Show full number if logged in
    }
    return 'XXXXXXXXX'; // Mask if not logged in
  }

  /// Check if contact data should be visible
  static bool canViewContactData() => _isLoggedIn;

  /// Simulate checking for app update (for testing)
  /// Set updateRequired to true to trigger update gate
  static void simulateUpdateRequired({bool updateRequired = true}) {
    _updateRequired = updateRequired;
  }
}
