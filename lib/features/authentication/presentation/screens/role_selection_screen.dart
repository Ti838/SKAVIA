import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../navigation/data/repositories/dashboard_repository.dart';

/// Screen allowing new and existing users to select their intent and active role.
/// Reverse-engineered from industry-standard multi-role applications (Upwork, Fiverr, TaskRabbit).
/// Zero initial pre-selection enforces deliberate user choice and initializes the correct mode.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  // Deliberately null to avoid making false assumptions on behalf of new users
  String? _selectedRole;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _roles = [
    {
      'id': 'customer',
      'titleEn': 'I Need Home Services & Technicians',
      'titleBn': 'ব্যক্তিগত গ্রাহক (সার্ভিস বুকিং)',
      'subtitleEn':
          'Hire certified electricians, AC technicians, plumbers with 4-digit OTP verification & secure payouts.',
      'subtitleBn':
          'বাসা-বাড়ির ইলেকট্রিশিয়ান, এসি, প্লাম্বার বুকিং এবং ওটিপি ভেরিফিকেশনে নিরাপদ সেবা।',
      'icon': Icons.person_search_rounded,
      'color': AppColors.primaryRoyal,
      'badgeEn': 'Individual Client',
      'badgeBn': 'ব্যক্তিগত',
    },
    {
      'id': 'enterprise',
      'titleEn': 'I Represent a Business / Corporate Entity',
      'titleBn': 'কর্পোরেট ক্লায়েন্ট (টার্নকি প্রজেক্ট)',
      'subtitleEn':
          'Assemble multidisciplinary specialist teams, manage turnkey commercial fit-outs, milestone escrow & VAT invoices.',
      'subtitleBn':
          'অফিস রিনোভেশন, টিম হায়ার, মাইলস্টোন এসক্রো ও ভ্যাট ইনভয়েস ম্যানেজমেন্ট।',
      'icon': Icons.business_center_rounded,
      'color': AppColors.successGreen,
      'badgeEn': 'Corporate & Turnkey',
      'badgeBn': 'প্রাতিষ্ঠানিক',
    },
    {
      'id': 'worker',
      'titleEn': 'I am a Skilled Specialist / Technician',
      'titleBn': 'দক্ষ কারিগর / টেকনিশিয়ান (কাজ ও আয়)',
      'subtitleEn':
          'Receive instant nearby job dispatches, complete jobs with client OTP, track ratings and withdraw wallet earnings to bKash.',
      'subtitleBn':
          'আশেপাশের কাজের রিকোয়েস্ট গ্রহণ, কাজ শেষে ওটিপিতে পেমেন্ট এবং বিকাশ/ব্যাংকে টাকা উত্তোলন।',
      'icon': Icons.handyman_rounded,
      'color': AppColors.accent,
      'badgeEn': 'Specialist & Worker',
      'badgeBn': 'কারিগর',
    },
  ];

  Future<void> _confirmSelection() async {
    if (_selectedRole == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await DashboardRepository().updateActiveMode(user.uid, _selectedRole!);
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isSaving = false);

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.appShell,
      arguments: {'initialMode': _selectedRole},
    );
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isBn = AppLanguageService.isBengali;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: _handleBack,
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                AppLanguageService.toggleLanguage();
              });
            },
            icon: const Icon(Icons.language_rounded, size: 16),
            label: Text(
              isBn ? 'Eng' : 'বাংলা',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBn
                    ? 'আপনি কিভাবে SKAVIA ব্যবহার করতে চান?'
                    : 'How do you want to use SKAVIA?',
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isBn
                    ? 'আপনার প্রয়োজন অনুযায়ী অ্যাকাউন্ট মোড সিলেক্ট করুন। পরবর্তীতে প্রোফাইল থেকে যেকোনো সময় মোড পরিবর্তন করতে পারবেন।'
                    : 'Select your primary role. You can freely switch between modes anytime from your dashboard.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.separated(
                  itemCount: _roles.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final role = _roles[index];
                    final isSelected = _selectedRole == role['id'];
                    final color = role['color'] as Color;

                    return InkWell(
                      onTap: () => setState(() => _selectedRole = role['id']),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLarge,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: isDark ? 0.18 : 0.08)
                              : (isDark
                                    ? colorScheme.surfaceContainerHighest
                                    : Colors.white),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLarge,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? color
                                : colorScheme.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? color.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.03),
                              blurRadius: isSelected ? 12 : 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                role['icon'] as IconData,
                                color: color,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          isBn
                                              ? (role['titleBn'] as String)
                                              : (role['titleEn'] as String),
                                          style: TextStyle(
                                            fontFamily:
                                                AppTypography.headingFont,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isBn
                                          ? (role['badgeBn'] as String)
                                          : (role['badgeEn'] as String),
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    isBn
                                        ? (role['subtitleBn'] as String)
                                        : (role['subtitleEn'] as String),
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: colorScheme.onSurfaceVariant,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? color : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? color
                                      : colorScheme.outline,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              AppButton(
                text: _isSaving
                    ? (isBn ? 'সংরক্ষণ করা হচ্ছে...' : 'Saving Choice...')
                    : (_selectedRole == null
                          ? (isBn
                                ? 'শুরু করতে একটি মোড নির্বাচন করুন'
                                : 'Select a Mode to Continue')
                          : (isBn
                                ? 'এই মোডে প্রবেশ করুন'
                                : 'Continue to Dashboard')),
                isLoading: _isSaving,
                onPressed: _selectedRole != null && !_isSaving
                    ? _confirmSelection
                    : null,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
