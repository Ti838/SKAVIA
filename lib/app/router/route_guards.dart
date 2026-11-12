import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/supabase_guard.dart';

/// Role and session permissions verification for SKAVIA.
abstract class RouteGuards {
  static const List<String> adminRoleNames = [
    'Super Admin',
    'Company Admin',
    'Branch Manager',
  ];

  /// Checks whether a valid Firebase Auth user session exists (fail-closed)
  static bool isAuthenticated() {
    try {
      return FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  /// Verifies if user has required role access
  static bool hasRole(String role, List<String> userRoles) {
    if (userRoles.contains('Super Admin') ||
        userRoles.contains('Company Admin')) {
      return true;
    }
    return userRoles.contains(role);
  }

  /// Verifies asynchronously whether the current signed-in Firebase user holds
  /// an internal SKAVIA admin role in `user_roles`. Fails closed (`false`) on errors.
  static Future<bool> hasAnyAdminRole({SupabaseClient? client}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;
      final sb = client ?? tryGetSupabaseClient();
      if (sb == null) return false;
      final res = await sb
          .from('user_roles')
          .select('roles(role_name)')
          .eq('user_id', user.uid);
      final roleNames = <String>[];
      for (final row in (res as List)) {
        final roleObj = row['roles'];
        if (roleObj is Map && roleObj['role_name'] != null) {
          roleNames.add(roleObj['role_name'].toString());
        }
      }
      return roleNames.any(adminRoleNames.contains);
    } catch (_) {
      return false;
    }
  }
}

/// Fail-closed Flutter route guard wrapper protecting legacy mobile admin screens.
/// Full admin operations are hosted in the dedicated Admin Web Portal (`admin-web/`).
class ProtectedAdminRoute extends StatelessWidget {
  final Widget child;
  final Future<bool> Function()? checkAdminAccess;

  const ProtectedAdminRoute({
    super.key,
    required this.child,
    this.checkAdminAccess,
  });

  @override
  Widget build(BuildContext context) {
    if (!RouteGuards.isAuthenticated()) {
      return const _UnauthorizedAdminView(
        title: 'Authentication Required',
        message:
            'Please sign in with an authorized SKAVIA administrator account.',
      );
    }

    return FutureBuilder<bool>(
      future: (checkAdminAccess ?? RouteGuards.hasAnyAdminRole)(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data != true) {
          return const _UnauthorizedAdminView(
            title: 'Restricted Admin Portal Access',
            message:
                'This module requires verified Super Admin, Company Admin, or Branch Manager privileges via the SKAVIA Admin Web Portal.',
          );
        }
        return child;
      },
    );
  }
}

class _UnauthorizedAdminView extends StatelessWidget {
  final String title;
  final String message;

  const _UnauthorizedAdminView({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access Restricted')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 52),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
