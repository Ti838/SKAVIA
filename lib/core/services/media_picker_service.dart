import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Platform-channel media picker allowing gallery/camera capture and native
/// JPEG compression without fragile external plugin version conflicts.
class MediaPickerService {
  MediaPickerService._();

  static const MethodChannel _channel = MethodChannel('skavia/media_picker');

  static Future<File?> pickImage({bool fromCamera = false}) async {
    if (kIsWeb) return null;
    try {
      final method = fromCamera ? 'pickCameraImage' : 'pickGalleryImage';
      final path = await _channel.invokeMethod<String>(method);
      if (path != null && path.trim().isNotEmpty) {
        final file = File(path);
        if (await file.exists()) {
          return file;
        }
      }
    } on MissingPluginException {
      debugPrint('[MediaPickerService] Native picker unavailable on platform.');
    } catch (e) {
      debugPrint('[MediaPickerService] Image pick error: $e');
    }
    return null;
  }

  /// Compresses an image (e.g., cropped PNG bytes) into a compact JPEG on Android.
  /// Returns the original file on non-Android/test environments.
  static Future<File> compressToJpeg(
    File inputFile, {
    int maxDimension = 1280,
    int quality = 88,
  }) async {
    if (kIsWeb) return inputFile;
    try {
      final path = await _channel.invokeMethod<String>('compressImageToJpeg', {
        'inputPath': inputFile.path,
        'maxDimension': maxDimension,
        'quality': quality,
      });
      if (path != null && path.trim().isNotEmpty) {
        final out = File(path);
        if (await out.exists()) {
          return out;
        }
      }
    } catch (_) {}
    return inputFile;
  }
}
