import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../domain/entities/diagnostic_report.dart';

/// Modal dialog detailing diagnostic privacy policies and providing report export.
class DiagnosticConsentDialog extends StatelessWidget {
  final DiagnosticReport? report;

  const DiagnosticConsentDialog({
    super.key,
    this.report,
  });

  static Future<void> show(BuildContext context, {DiagnosticReport? report}) {
    return showDialog(
      context: context,
      builder: (ctx) => DiagnosticConsentDialog(report: report),
    );
  }

  void _copyReport(BuildContext context) {
    if (report == null) return;
    final jsonStr = report!.toJson().toString();
    Clipboard.setData(ClipboardData(text: jsonStr));
    Navigator.of(context).pop();
    UiFeedbackHelper.showSuccess(
      context,
      AppLanguageService.isBengali
          ? 'ডায়াগনস্টিক রিপোর্ট কপি করা হয়েছে'
          : 'Diagnostic report copied to clipboard',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(
            Icons.shield_outlined,
            color: AppColors.primaryBlue,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isBn ? 'প্রাইভেসি ও ডেটা নিরাপত্তা' : 'Privacy & Data Safety',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildItem(
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.successGreen,
              title: isBn ? 'লোকাল প্রসেসিং' : 'Strictly Local Processing',
              desc: isBn
                  ? 'সমস্ত ডায়াগনস্টিক তথ্য সম্পূর্ণভাবে আপনার ফোনেই যাচাই হয়। আপনার সম্মতি ছাড়া কোনো রিপোর্ট কোথাও পাঠানো হয় না।'
                  : 'All diagnostic evaluations run 100% locally on your device. Nothing is sent without your explicit consent.',
            ),
            const SizedBox(height: 12),
            _buildItem(
              icon: Icons.block_rounded,
              color: AppColors.errorRed,
              title: isBn ? 'জিরো ট্র্যাকিং আইডেন্টিফায়ার' : 'Zero Persistent Trackers',
              desc: isBn
                  ? 'আমরা কোনো IMEI, সিরিয়াল নম্বর, বা হার্ডওয়্যার ট্র্যাকিং আইডি সংগ্রহ করি না।'
                  : 'SKAVIA never queries or records IMEI, IMSI, or persistent hardware serial identifiers.',
            ),
            const SizedBox(height: 12),
            _buildItem(
              icon: Icons.location_off_outlined,
              color: AppColors.warningAmber,
              title: isBn ? 'জিরো লোকেশন লগিং' : 'Zero Coordinate Logging',
              desc: isBn
                  ? 'ডায়াগনস্টিকে কেবল জিপিএস সেন্সর সচল আছে কি না পরীক্ষা হয়; আপনার বর্তমান অবস্থান সংরক্ষণ করা হয় না।'
                  : 'Diagnostic checks only verify if the GPS sensor is operational; your latitude and longitude are never recorded.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(isBn ? 'বন্ধ করুন' : 'Close'),
        ),
        if (report != null)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: Text(isBn ? 'রিপোর্ট কপি করুন' : 'Copy Report JSON'),
            onPressed: () => _copyReport(context),
          ),
      ],
    );
  }

  Widget _buildItem({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
