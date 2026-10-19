/// Practical String utility extensions.
extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isNotEmpty ? word.capitalize() : '')
        .join(' ');
  }

  bool get isValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(trim());
  }

  bool get isValidBdPhone {
    final clean = replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^(?:\+?88)?01[3-9]\d{8}$').hasMatch(clean);
  }
}
