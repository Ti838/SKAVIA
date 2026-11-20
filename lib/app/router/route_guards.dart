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

  /// Checks whether a valid Firebase Auth user session exists (fail-closed).
  static bool isAuthenticated() {
    try {
      return FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  /// Verifies if user has required role access.
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
/// Caches the verification future in State so theme/locale rebuilds do not
/// re-trigger backend permission queries.
class ProtectedAdminRoute extends StatefulWidget {
  final Widget child;
  final Future<bool> Function()? checkAdminAccess;

  const ProtectedAdminRoute({
    super.key,
    required this.child,
    this.checkAdminAccess,
  });

  @override
  State<ProtectedAdminRoute> createState() => _ProtectedAdminRouteState();
}

class _ProtectedAdminRouteState extends State<ProtectedAdminRoute> {
  Future<bool>? _accessFuture;

  @override
  void initState() {
    super.initState();
    if (RouteGuards.isAuthenticated()) {
      _accessFuture =
          (widget.checkAdminAccess ?? RouteGuards.hasAnyAdminRole)();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!RouteGuards.isAuthenticated() || _accessFuture == null) {
      return const _UnauthorizedAdminView(
        title: 'Authentication Required',
        message:
            'Please sign in with an authorized SKAVIA administrator account.',
      );
    }

    return FutureBuilder<bool>(
      future: _accessFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data != true) {
          return const _UnauthorizedAdminView(
            title: 'Restricted Admin Portal Access',
            message: 'This module requires verified Super Admin, Company Admin, or Branch Manager privileges via the SKAVIA Admin Web Portal.',
          );
        }
        return widget.child;
      },
    );
  }
}

class _UnauthorizedAdminView extends StatelessWidget {
  final String title;
  final String message;

  const _UnauthorizedAdminView({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Access Restricted')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 40,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
