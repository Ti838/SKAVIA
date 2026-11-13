import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AndroidInstallerException implements Exception {
  final String code;
  final String message;

  AndroidInstallerException(this.code, this.message);

  @override
  String toString() => 'AndroidInstallerException($code): $message';
}

abstract class AndroidInstallerPlatform {
  Future<String?> getUpdatesDirectoryPath();
  Future<int?> getAndroidSdkInt();
  Future<bool> canRequestPackageInstalls();
  Future<bool> openUnknownAppSourcesSettings();
  Future<String> computeFileSha256(String filePath);
  Future<bool> installApk(String filePath);
}

class MethodChannelAndroidInstaller implements AndroidInstallerPlatform {
  static const MethodChannel _channel = MethodChannel('skavia/app_installer');

  @override
  Future<String?> getUpdatesDirectoryPath() async {
    if (kIsWeb) return null;
    final res = await _channel.invokeMapMethod<String, dynamic>(
      'getUpdateDirectories',
    );
    return res?['updatesDir']?.toString();
  }

  @override
  Future<int?> getAndroidSdkInt() async {
    if (kIsWeb) return null;
    return await _channel.invokeMethod<int>('getAndroidSdkInt');
  }

  @override
  Future<bool> canRequestPackageInstalls() async {
    if (kIsWeb) return false;
    final res = await _channel.invokeMethod<bool>('canRequestPackageInstalls');
    return res ?? false;
  }

  @override
  Future<bool> openUnknownAppSourcesSettings() async {
    if (kIsWeb) return false;
    final res =
        await _channel.invokeMethod<bool>('openUnknownAppSourcesSettings');
    return res ?? false;
  }

  @override
  Future<String> computeFileSha256(String filePath) async {
    try {
      final hash = await _channel.invokeMethod<String>(
        'computeFileSha256',
        {'filePath': filePath},
      );
      if (hash == null || hash.isEmpty) {
        throw AndroidInstallerException(
          'HASH_EMPTY',
          'Empty SHA-256 digest returned from native verifier.',
        );
      }
      return hash.toLowerCase();
    } on PlatformException catch (e) {
      throw AndroidInstallerException(
        e.code,
        e.message ?? 'Failed computing SHA-256 checksum.',
      );
    }
  }

  @override
  Future<bool> installApk(String filePath) async {
    try {
      final launched = await _channel.invokeMethod<bool>(
        'installApk',
        {'filePath': filePath},
      );
      return launched ?? false;
    } on PlatformException catch (e) {
      throw AndroidInstallerException(
        e.code,
        e.message ?? 'Failed launching Android Package Installer.',
      );
    }
  }
}

