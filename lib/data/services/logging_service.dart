import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Central audit and diagnostic logging service.
class LoggingService {
  static void log(String message, {String category = 'APP', dynamic details}) {
    debugPrint('[$category] $message ${details != null ? '=> $details' : ''}');
  }

  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    debugPrint('[ERROR] $message: $error');
    if (stackTrace != null) {
      debugPrint('[STACK] $stackTrace');
    }
  }

  static Future<void> recordAuditLog({
    required String action,
    required String performedBy,
    required String entityType,
    String? entityId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await Supabase.instance.client.from('audit_logs').insert({
        'action': action,
        'user_id': performedBy,
        'entity_type': entityType,
        'entity_id': entityId,
        'metadata': metadata,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }
}
