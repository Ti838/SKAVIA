import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/tables/database_tables.dart';
import '../utils/supabase_guard.dart';

class StorageUploadResult {
  final String? url;
  final String? errorMessage;

  const StorageUploadResult({this.url, this.errorMessage});
  bool get isSuccess => url != null && url!.isNotEmpty;
}

/// Remote storage datasource managing media, documents, and avatar uploads.
/// Uses authenticated UID-scoped paths and canonical [StorageBuckets] buckets.
class RemoteStorageDataSource {
  final FirebaseStorage? _firebaseStorage;
  final SupabaseClient? _supabase;

  static const Set<String> _allowedBuckets = {
    StorageBuckets.avatars,
    StorageBuckets.portfolios,
    StorageBuckets.certificates,
    StorageBuckets.verifications,
    StorageBuckets.attachments,
  };

  RemoteStorageDataSource({
    FirebaseStorage? firebaseStorage,
    SupabaseClient? supabaseClient,
  }) : _firebaseStorage = firebaseStorage ?? _tryGetFirebaseStorage(),
       _supabase = supabaseClient ?? tryGetSupabaseClient();

  static FirebaseStorage? _tryGetFirebaseStorage() {
    try {
      return FirebaseStorage.instance;
    } catch (_) {
      return null;
    }
  }

  /// Uploads a file with explicit bucket selection and returns a structured result
  /// surfacing clear failure reasons when authentication or upload fails.
  Future<StorageUploadResult> uploadFileDetailed({
    required File file,
    required String path,
    String bucket = StorageBuckets.attachments,
    String? mimeType,
    void Function(double progress)? onProgress,
  }) async {
    String? currentUid;
    try {
      currentUid = FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {}
    currentUid ??= _supabase?.auth.currentUser?.id;
    if (currentUid == null || currentUid.isEmpty) {
      return const StorageUploadResult(
        errorMessage: 'Sign in required before uploading files.',
      );
    }

    if (!_allowedBuckets.contains(bucket)) {
      return StorageUploadResult(
        errorMessage: 'Unsupported storage bucket: $bucket',
      );
    }

    final cleanRelativePath = path.replaceFirst(RegExp(r'^/+'), '');
    final scopedPath = cleanRelativePath.startsWith('$currentUid/')
        ? cleanRelativePath
        : '$currentUid/$cleanRelativePath';

    try {
      final fbStorage = _firebaseStorage;
      if (fbStorage == null) {
        throw StateError('Firebase Storage unavailable');
      }
      final ref = fbStorage.ref().child('$bucket/$scopedPath');
      final metadata = SettableMetadata(contentType: mimeType);
      final task = ref.putFile(file, metadata);
      if (onProgress != null) {
        task.snapshotEvents.listen((snapshot) {
          if (snapshot.totalBytes > 0) {
            onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
          }
        });
      }
      final uploadTask = await task;
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return StorageUploadResult(url: downloadUrl);
    } catch (e) {
      debugPrint('[RemoteStorageDataSource] Firebase upload notice: $e');
      final supabase = _supabase;
      if (supabase == null) {
        return const StorageUploadResult(
          errorMessage: 'Storage service unavailable.',
        );
      }
      try {
        final bytes = await file.readAsBytes();
        await supabase.storage
            .from(bucket)
            .uploadBinary(
              scopedPath,
              bytes,
              fileOptions: FileOptions(contentType: mimeType, upsert: true),
            );
        final resolvedUrl = bucket == StorageBuckets.verifications
            ? scopedPath
            : supabase.storage.from(bucket).getPublicUrl(scopedPath);
        return StorageUploadResult(url: resolvedUrl);
      } catch (err) {
        debugPrint('[RemoteStorageDataSource] Supabase fallback error: $err');
        return const StorageUploadResult(
          errorMessage: 'Upload failed. Check network or storage permissions.',
        );
      }
    }
  }

  /// Backward-compatible convenience helper returning URL or null on failure.
  Future<String?> uploadFile({
    required File file,
    required String path,
    String bucket = StorageBuckets.attachments,
    String? mimeType,
  }) async {
    final result = await uploadFileDetailed(
      file: file,
      path: path,
      bucket: bucket,
      mimeType: mimeType,
    );
    return result.url;
  }
}
