import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote storage datasource managing media, documents, and avatar uploads.
class RemoteStorageDataSource {
  final FirebaseStorage _firebaseStorage;
  final SupabaseClient _supabase;

  RemoteStorageDataSource({
    FirebaseStorage? firebaseStorage,
    SupabaseClient? supabaseClient,
  }) : _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance,
       _supabase = supabaseClient ?? Supabase.instance.client;

  /// Uploads a file to Firebase Storage or Supabase Storage and returns public URL
  Future<String?> uploadFile({
    required File file,
    required String path,
    String? mimeType,
  }) async {
    try {
      final ref = _firebaseStorage.ref().child(path);
      final metadata = SettableMetadata(contentType: mimeType);
      final uploadTask = await ref.putFile(file, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('[RemoteStorageDataSource] Firebase upload notice: $e');
      try {
        // Fallback to Supabase Storage
        final bytes = await file.readAsBytes();
        await _supabase.storage.from('media').uploadBinary(path, bytes);
        return _supabase.storage.from('media').getPublicUrl(path);
      } catch (err) {
        debugPrint('[RemoteStorageDataSource] Supabase fallback error: $err');
        return null;
      }
    }
  }
}
