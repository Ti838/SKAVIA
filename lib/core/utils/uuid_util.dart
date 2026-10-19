import 'dart:math';

/// RFC 4122 Version 4 UUID generator & validator
/// Pure Dart, zero external dependencies, 100% compliant with PostgreSQL UUID.
class UuidUtil {
  static final Random _secureRandom = Random.secure();

  /// Alias for generateV4()
  static String generateUuidV4() => generateV4();

  /// Generates a crypto-random RFC 4122 Version 4 UUID string
  static String generateV4() {
    final bytes = List<int>.generate(16, (_) => _secureRandom.nextInt(256));
    // Set version to 4 (0100)
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    // Set variant to IETF (10xx)
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final buffer = StringBuffer();
    for (int i = 0; i < 16; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) buffer.write('-');
      buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString().toLowerCase();
  }

  /// Validates whether a given string is a valid UUID
  static bool isValidUuid(String? str) {
    if (str == null || str.trim().isEmpty) return false;
    final regex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    return regex.hasMatch(str.trim());
  }

  /// Returns input if valid UUID; otherwise generates a new valid V4 UUID
  static String ensureValidUuid(String? str) {
    if (isValidUuid(str)) {
      return str!.trim().toLowerCase();
    }
    return generateV4();
  }
}
