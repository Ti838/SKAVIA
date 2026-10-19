import 'package:firebase_auth/firebase_auth.dart';

/// Role and session permissions verification for SKAVIA.
abstract class RouteGuards {
  /// Checks whether a valid Firebase Auth user session exists
  static bool isAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// Verifies if user has required role access
  static bool hasRole(String role, List<String> userRoles) {
    if (userRoles.contains('Super Admin') ||
        userRoles.contains('Company Admin')) {
      return true;
    }
    return userRoles.contains(role);
  }
}
