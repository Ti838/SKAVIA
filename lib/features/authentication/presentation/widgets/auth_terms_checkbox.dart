import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/motion/sakuga_checkbox.dart';

/// Terms of Service and Privacy Policy acceptance checkbox row with legal modals.
class AuthTermsCheckbox extends StatelessWidget {
  final bool value;
  final String? errorText;
  final ValueChanged<bool> onChanged;

  const AuthTermsCheckbox({
    super.key,
    required this.value,
    this.errorText,
    required this.onChanged,
  });

  void _showLegalDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isBn = context.isBengali;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SakugaCheckbox(
              value: value,
              semanticLabel: isBn
                  ? 'শর্তাবলী ও গোপনীয়তা নীতি গ্রহণ করুন'
                  : 'Agree to Terms and Privacy Policy',
              activeColor: const Color(0xFF003399),
              onChanged: onChanged,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    isBn ? 'আমি ' : 'I agree to the ',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showLegalDialog(
                      context,
                      isBn ? 'সেবার শর্তাবলী' : 'Terms of Service',
                      isBn
                          ? 'SKAVIA ব্যবহার করার মাধ্যমে আপনি আমাদের প্ল্যাটফর্ম সেবার শর্তাবলী, এসক্রো নিয়মাবলী এবং কর্মক্ষেত্রের মান মেনে চলতে সম্মত হচ্ছেন।'
                          : 'By accessing or using SKAVIA, you agree to be bound by our platform service terms, verified operational procedures, escrow rules, and workplace safety standards.',
                    ),
                    child: Text(
                      isBn ? 'সেবার শর্তাবলী' : 'Terms of Service',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFF3898EC)
                            : const Color(0xFF003399),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(
                    isBn ? ' এবং ' : ' and ',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showLegalDialog(
                      context,
                      isBn ? 'গোপনীয়তা নীতি' : 'Privacy Policy',
                      isBn
                          ? 'SKAVIA আপনার ব্যক্তিগত তথ্য ডেটা সুরক্ষা আইন ও ক্রিপ্টোগ্রাফিক সুরক্ষা অনুযায়ী নিরাপদে সংরক্ষণ করে।'
                          : 'SKAVIA collects and protects your personal data in accordance with our national data protection obligations and cryptographic access security rules.',
                    ),
                    child: Text(
                      isBn ? 'গোপনীয়তা নীতি' : 'Privacy Policy',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFF3898EC)
                            : const Color(0xFF003399),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  if (isBn)
                    Text(
                      ' মেনে নিচ্ছি',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              errorText!,
              style: TextStyle(
                fontSize: 11.5,
                color: colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
