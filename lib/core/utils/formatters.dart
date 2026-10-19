import 'package:intl/intl.dart';

/// Formatting utilities for currency, numbers, dates, and phone numbers.
abstract class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat('#,##,##0', 'en_US');
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  /// Formats amount in BDT (৳) currency
  static String formatCurrency(num amount, {bool showSymbol = true}) {
    final formatted = _currencyFormat.format(amount);
    return showSymbol ? '৳ $formatted' : formatted;
  }

  /// Formats date: "19 Oct 2026"
  static String formatDate(DateTime date) => _dateFormat.format(date);

  /// Formats time: "03:15 PM"
  static String formatTime(DateTime date) => _timeFormat.format(date);

  /// Formats full datetime: "19 Oct 2026, 03:15 PM"
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  /// Formats human-friendly relative time ("2m ago", "1h ago", "Yesterday")
  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(dateTime);
  }

  /// Formats standard Bangladeshi phone number
  static String formatBdPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 11 && clean.startsWith('01')) {
      return '+880 ${clean.substring(1, 5)}-${clean.substring(5)}';
    }
    if (clean.length == 13 && clean.startsWith('8801')) {
      return '+880 ${clean.substring(3, 7)}-${clean.substring(7)}';
    }
    return phone;
  }
}
