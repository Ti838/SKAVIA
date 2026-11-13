import 'dart:math';

/// Helpers for generating and extracting 4-digit anti-fraud Job Security OTPs
/// stored in `service_requests.service_notes`.
abstract class JobOtpUtil {
  static final Random _secureRandom = Random.secure();
  static final RegExp _otpRegex = RegExp(
    r'OTP[:\s#-]*(\d{4})',
    caseSensitive: false,
  );

  /// Generates a random 4-digit numeric OTP in `1000..9999`.
  static String generateOtp() {
    final code = 1000 + _secureRandom.nextInt(9000);
    return code.toString();
  }

  /// Extracts a 4-digit OTP from [serviceNotes] (e.g. `OTP: 4829`), or falls
  /// back cleanly to a deterministic 4-character suffix if legacy rows omitted it.
  static String extractOtp(
    String? serviceNotes, {
    String? fallbackRequestId,
  }) {
    final notes = serviceNotes?.trim() ?? '';
    if (notes.isNotEmpty) {
      final match = _otpRegex.firstMatch(notes);
      if (match != null && match.group(1) != null) {
        return match.group(1)!;
      }
    }

    final reqId = (fallbackRequestId ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (reqId.length >= 4) {
      return reqId.substring(reqId.length - 4);
    }

    final raw = (fallbackRequestId ?? '').trim();
    if (raw.length >= 4) {
      return raw.substring(raw.length - 4).toUpperCase();
    }

    return '4829';
  }
}

