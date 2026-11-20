import 'package:intl/intl.dart';

import '../services/app_language_service.dart';

/// Formatting utilities for currency, numbers, dates, and phone numbers.
/// Supports dual-script Bengali (বাংলা) and English formatting.
abstract class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat('#,##,##0', 'en_US');
  static final DateFormat _dateFormatEn = DateFormat('dd MMM yyyy');
  static final DateFormat _timeFormatEn = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormatEn = DateFormat('dd MMM yyyy, hh:mm a');

  static const Map<String, String> _bnDigits = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };

  static const List<String> _bnMonths = [
    '',
    'জানুয়ারি',
    'ফেব্রুয়ারি',
    'মার্চ',
    'এপ্রিল',
    'মে',
    'জুন',
    'জুলাই',
    'আগস্ট',
    'সেপ্টেম্বর',
    'অক্টোবর',
    'নভেম্বর',
    'ডিসেম্বর',
  ];

  /// Converts ASCII digits (0-9) to Bengali digits (০-৯)
  static String toBengaliDigits(dynamic input) {
    var result = input.toString();
    _bnDigits.forEach((en, bn) {
      result = result.replaceAll(en, bn);
    });
    return result;
  }

  /// Formats amount in BDT (৳) currency with script-aware numerals
  static String formatCurrency(
    num amount, {
    bool showSymbol = true,
    bool? useBnDigits,
  }) {
    final formatted = _currencyFormat.format(amount);
    final isBn = useBnDigits ?? AppLanguageService.isBengali;
    final display = isBn ? toBengaliDigits(formatted) : formatted;
    return showSymbol ? '৳ $display' : display;
  }

  /// Formats date: "19 Oct 2026" or "১৯ অক্টোবর ২০২৬"
  static String formatDate(DateTime date, {bool? useBn}) {
    final isBn = useBn ?? AppLanguageService.isBengali;
    if (isBn) {
      final day = toBengaliDigits(date.day);
      final month = _bnMonths[date.month.clamp(1, 12)];
      final year = toBengaliDigits(date.year);
      return '$day $month $year';
    }
    return _dateFormatEn.format(date);
  }

  /// Formats time: "03:15 PM" or "০৩:১৫ PM"
  static String formatTime(DateTime date, {bool? useBn}) {
    final formatted = _timeFormatEn.format(date);
    final isBn = useBn ?? AppLanguageService.isBengali;
    if (isBn) {
      return toBengaliDigits(formatted);
    }
    return formatted;
  }

  /// Formats full datetime: "19 Oct 2026, 03:15 PM"
  static String formatDateTime(DateTime date, {bool? useBn}) {
    final isBn = useBn ?? AppLanguageService.isBengali;
    if (isBn) {
      return '${formatDate(date, useBn: true)}, ${formatTime(date, useBn: true)}';
    }
    return _dateTimeFormatEn.format(date);
  }

  /// Formats human-friendly relative time ("Just now", "2m ago", "Yesterday" / "এইমাত্র", "২ মিনিট আগে", "গতকাল")
  static String timeAgo(DateTime dateTime, {bool? useBn}) {
    final isBn = useBn ?? AppLanguageService.isBengali;
    final diff = DateTime.now().difference(dateTime);

    if (isBn) {
      if (diff.inSeconds < 60) return 'এইমাত্র';
      if (diff.inMinutes < 60) {
        return '${toBengaliDigits(diff.inMinutes)} মিনিট আগে';
      }
      if (diff.inHours < 24) {
        return '${toBengaliDigits(diff.inHours)} ঘণ্টা আগে';
      }
      if (diff.inDays == 1) return 'গতকাল';
      if (diff.inDays < 7) {
        return '${toBengaliDigits(diff.inDays)} দিন আগে';
      }
      return formatDate(dateTime, useBn: true);
    }

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(dateTime, useBn: false);
  }

  /// Formats byte counts cleanly into KB or MB for APK & attachment labels.
  static String formatFileSize(int bytes, {bool? useBn}) {
    final isBn = useBn ?? AppLanguageService.isBengali;
    if (bytes <= 0) return isBn ? '০ B' : '0 B';
    final mb = bytes / (1024 * 1024);
    if (mb >= 1) {
      final str = mb.toStringAsFixed(1);
      return '${isBn ? toBengaliDigits(str) : str} MB';
    }
    final kbStr = (bytes / 1024).toStringAsFixed(0);
    return '${isBn ? toBengaliDigits(kbStr) : kbStr} KB';
  }

  /// Formats standard Bangladeshi phone number
  static String formatBdPhone(String phone, {bool? useBn}) {
    final isBn = useBn ?? AppLanguageService.isBengali;
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    String formatted = phone;
    if (clean.length == 11 && clean.startsWith('01')) {
      formatted = '+880 ${clean.substring(1, 5)}-${clean.substring(5)}';
    } else if (clean.length == 13 && clean.startsWith('8801')) {
      formatted = '+880 ${clean.substring(3, 7)}-${clean.substring(7)}';
    }
    return isBn ? toBengaliDigits(formatted) : formatted;
  }
}
