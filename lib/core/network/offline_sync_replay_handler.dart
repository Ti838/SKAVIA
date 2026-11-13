import 'package:firebase_auth/firebase_auth.dart';

import '../../data/tables/database_tables.dart';
import '../utils/supabase_guard.dart';
import 'offline_sync_queue_manager.dart';

/// Executes queued offline mutations against Supabase once connectivity restores.
abstract class OfflineSyncReplayHandler {
  static Future<bool> replay(SyncQueueItem item) async {
    final client = tryGetSupabaseClient();
    if (client == null) return false;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    final payload = item.payload;

    switch (item.operationType) {
      case 'update_profile':
        final targetId = payload['id']?.toString() ?? currentUser.uid;
        if (targetId != currentUser.uid) return false;
        final updateFields = <String, dynamic>{
          if (payload['full_name'] != null) 'full_name': payload['full_name'],
          if (payload['phone'] != null) 'phone': payload['phone'],
          if (payload['avatar_url'] != null)
            'avatar_url': payload['avatar_url'],
          if (payload['cover_url'] != null)
            'cover_url': payload['cover_url'],
          if (payload['date_of_birth'] != null)
            'date_of_birth': payload['date_of_birth'],
          if (payload['birthday_notifications_enabled'] != null)
            'birthday_notifications_enabled':
                payload['birthday_notifications_enabled'],
          if (payload['gender'] != null) 'gender': payload['gender'],
          if (payload['emergency_contact_name'] != null)
            'emergency_contact_name': payload['emergency_contact_name'],
          if (payload['emergency_contact_phone'] != null)
            'emergency_contact_phone': payload['emergency_contact_phone'],
          if (payload['preferred_language'] != null)
            'preferred_language': payload['preferred_language'],
          if (payload['timezone'] != null) 'timezone': payload['timezone'],
          if (payload['privacy_settings'] != null)
            'privacy_settings': payload['privacy_settings'],
          if (payload['notification_preferences'] != null)
            'notification_preferences': payload['notification_preferences'],
          if (payload['profile_completion_percentage'] != null)
            'profile_completion_percentage':
                payload['profile_completion_percentage'],
        };
        await client
            .from(DatabaseTables.users)
            .update(updateFields)
            .eq('user_id', currentUser.uid);
        if (payload['customer_type'] != null ||
            payload['company_name'] != null ||
            payload['trade_license'] != null ||
            payload['billing_address'] != null) {
          await client.from(DatabaseTables.customerProfiles).upsert({
            'user_id': currentUser.uid,
            'customer_type': payload['customer_type'] ?? 'Individual',
            'company_name': payload['company_name'],
            'trade_license': payload['trade_license'],
            'billing_address': payload['billing_address'],
          }, onConflict: 'user_id');
        }
        return true;

      case 'submit_complaint':
        final complaint = Map<String, dynamic>.from(payload);
        complaint['filed_by'] = currentUser.uid;
        await client.from(DatabaseTables.complaints).insert(complaint);
        return true;

      case 'save_address':
        final addr = Map<String, dynamic>.from(payload);
        addr['user_id'] = currentUser.uid;
        await client.from(DatabaseTables.userAddresses).upsert(addr);
        return true;

      case 'send_message':
        final msg = Map<String, dynamic>.from(payload);
        msg['sender_id'] = currentUser.uid;
        await client.from(DatabaseTables.messages).insert(msg);
        return true;

      case 'post_requirement':
        final reqPayload = Map<String, dynamic>.from(payload);
        reqPayload['submitted_by'] = currentUser.uid;
        await client.from(DatabaseTables.requirements).insert(reqPayload);
        return true;

      default:
        return false;
    }
  }
}

