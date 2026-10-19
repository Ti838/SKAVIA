import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';

/// Modal bottom sheet displaying verified legal terms, privacy policies, fee schedules, and escrow rules.
/// Fulfills Section 14 (Product Owner Decision Authority) for transparent marketplace rules.
class LegalPoliciesSheet extends StatelessWidget {
  const LegalPoliciesSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const LegalPoliciesSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primarySky.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.gavel_rounded,
                      color: AppColors.primaryRoyal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isBn
                        ? 'আইনি নীতিমালা ও শর্তাবলী'
                        : 'Legal & Platform Policies',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 16),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildPolicyCard(
                  context,
                  icon: Icons.verified_user_rounded,
                  title: isBn
                      ? 'ব্যবহারের শর্তাবলী (Terms of Service)'
                      : 'Terms of Service (v1.2)',
                  subtitle: isBn
                      ? 'গ্রাহক ও কারিগরের অধিকার, আচরণবিধি এবং জব বুকিংয়ের নিয়মাবলী।'
                      : 'Rules, user responsibilities, and booking agreement for clients & workers.',
                  details: isBn
                      ? '• গ্রাহক সন্তুষ্টি সাপেক্ষে জব সম্পন্ন ঘোষিত হবে।\n• সরাসরি ব্যক্তিগত পেমেন্ট লেনদেন নিষিদ্ধ; সকল বুকিং স্ক্যাভিয়া প্ল্যাটফর্মের মাধ্যমে নথিভুক্ত হতে হবে।\n• জরুরি নিরাপত্তা নীতিমালায় জিরো টলারেন্স নীতি প্রযোজ্য।'
                      : '• Jobs are completed only upon customer satisfaction and secret OTP verification.\n• Offline circumvention is strictly prohibited to preserve warranty and escrow safety.\n• Zero tolerance for harassment, fraudulent profiles, or unauthorized identity usage.',
                ),
                const SizedBox(height: 12),
                _buildPolicyCard(
                  context,
                  icon: Icons.shield_rounded,
                  title: isBn
                      ? 'গোপনীয়তা ও তথ্য সুরক্ষা (Privacy Policy)'
                      : 'Privacy Policy & Data Rights',
                  subtitle: isBn
                      ? 'আপনার ব্যক্তিগত ডেটা কীভাবে প্রক্রিয়া ও সুরক্ষিত রাখা হয়।'
                      : 'How your personal data, location, and phone number are handled securely.',
                  details: isBn
                      ? '• কোনো অপ্রয়োজনীয় ডেটা সংগ্রহ করা হয় না।\n• জাতীয় পরিচয়পত্র ও পুলিশ ক্লিয়ারেন্স এনক্রিপ্ট করে ক্লাউড স্টোরেজে রাখা হয়।\n• আপনি যেকোনো সময় আপনার অ্যাকাউন্ট ও ডেটা সম্পূর্ণ মুছে ফেলার অধিকার রাখেন।'
                      : '• Data minimization: We only collect information required for job delivery.\n• NID documents are encrypted in restricted enterprise storage.\n• You have the right to request full account deletion and data export at any time.',
                ),
                const SizedBox(height: 12),
                _buildPolicyCard(
                  context,
                  icon: Icons.payments_rounded,
                  title: isBn
                      ? 'স্বচ্ছ প্ল্যাটফর্ম ফি তালিকা (Fee Schedule)'
                      : 'Transparent Fee Schedule',
                  subtitle: isBn
                      ? 'কোনো লুকায়িত খরচ নেই: গ্রাহকদের জন্য ১০০% ফ্রি রেজিস্ট্রেশন ও বুকিং।'
                      : 'Zero hidden fees: Free for clients, 15% platform commission on worker payout.',
                  details: isBn
                      ? '• গ্রাহকদের জন্য প্ল্যাটফর্ম চার্জ: ৳০ (ফ্রি)।\n• ভেরিফায়েড কারিগর কমিশন: প্রতি সম্পন্ন কাজের মূল্যের ১৫%।\n• অবশিষ্ট ৮৫% অর্থ সরাসরি কারিগরের ওয়ালেট/ব্যাংকে জমা হয়।'
                      : '• Client Booking Surcharge: 0% (Completely free for clients).\n• Worker Commission: 15% of agreed job fare for platform maintenance & insurance.\n• 85% is directly disbursed to the verified technician upon job completion.',
                ),
                const SizedBox(height: 12),
                _buildPolicyCard(
                  context,
                  icon: Icons.lock_clock_rounded,
                  title: isBn
                      ? 'এস্ক্রো ও বাতিল নীতিমালা (Escrow & Cancellation)'
                      : 'Escrow & Cancellation Policy',
                  subtitle: isBn
                      ? 'নিরাপদ জব ওটিপি এস্ক্রো এবং বিরোধ নিষ্পত্তি।'
                      : 'Secure job OTP release mechanism and fair dispute resolution.',
                  details: isBn
                      ? '• কাজ শুরুর পূর্বে কোনো অর্থ কারিগরের নিকট হস্তান্তর হয় না।\n• গ্রাহক কাজ পরিদর্শন করে ৪-ডিজিটের গোপন ওটিপি প্রদানের পরেই অর্থ রিলিজ হয়।\n• কাজ শুরুর আগে বাতিল করলে শতভাগ অর্থ ফেরতযোগ্য।'
                      : '• Funds are never released to workers prior to physical inspection.\n• Client must verify work and provide the 4-digit secret Job OTP to release payout.\n• Free cancellation before technician dispatch; fair dispute mediation via admin support.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String details,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primaryRoyal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              details,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
