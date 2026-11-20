import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/database_tables.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../widgets/role_option_card.dart';

/// Screen allowing new and existing users to select their intent and active role.
/// Zero initial pre-selection enforces deliberate user choice and persists both
/// active workspace mode (`customer` | `enterprise` | `worker`) and SRS
/// `customer_profiles.customer_type` (`Individual` | `Business Client` | `Organization`).
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  String _corporateSubtype = 'Business Client';
  bool _isSaving = false;

  final List<Map<String, dynamic>> _roles = [
    {
      'id': 'customer',
      'titleEn': 'I Need Home Services & Technicians',
      'titleBn': 'ব্যক্তিগত গ্রাহক (সার্ভিস বুকিং)',
      'subtitleEn': 'Hire certified electricians, AC technicians, plumbers with 4-digit OTP verification & secure payouts.',
      'subtitleBn': 'বাসা-বাড়ির ইলেকট্রিশিয়ান, এসি, প্লাম্বার বুকিং এবং ওটিপি ভেরিফিকেশনে নিরাপদ সেবা।',
      'icon': Icons.person_search_rounded,
      'color': AppColors.primaryRoyal,
      'badgeEn': 'Individual Customer',
      'badgeBn': 'ব্যক্তিগত গ্রাহক',
    },
    {
      'id': 'enterprise',
      'titleEn': 'I Represent a Business / Organization',
      'titleBn': 'ব্যবসা বা প্রতিষ্ঠান (টার্নকি প্রজেক্ট)',
      'subtitleEn': 'Assemble multidisciplinary specialist teams, manage turnkey commercial fit-outs, milestone escrow & VAT invoices.',
      'subtitleBn': 'অফিস রিনোভেশন, টিম হায়ার, মাইলস্টোন এসক্রো ও ভ্যাট ইনভয়েস ম্যানেজমেন্ট।',
      'icon': Icons.business_center_rounded,
      'color': AppColors.successGreen,
      'badgeEn': 'Business / Organization',
      'badgeBn': 'ব্যবসা / প্রতিষ্ঠান',
    },
    {
      'id': 'worker',
      'titleEn': 'I am a Skilled Specialist / Technician',
      'titleBn': 'দক্ষ কারিগর / টেকনিশিয়ান (কাজ ও আয়)',
      'subtitleEn': 'Receive instant nearby job dispatches, complete jobs with client OTP, track ratings and withdraw wallet earnings to bKash.',
      'subtitleBn': 'আশেপাশের কাজের রিকোয়েস্ট গ্রহণ, কাজ শেষে ওটিপিতে পেমেন্ট এবং বিকাশ/ব্যাংকে টাকা উত্তোলন।',
      'icon': Icons.handyman_rounded,
      'color': AppColors.accentCoral,
      'badgeEn': 'Specialist & Worker',
      'badgeBn': 'কারিগর',
    },
  ];

  String? _resolveCurrentUserId() {
    try {
      final fbUid = FirebaseAuth.instance.currentUser?.uid;
      if (fbUid != null && fbUid.isNotEmpty) return fbUid;
    } catch (_) {}
    try {
      final spUid = tryGetSupabaseClient()?.auth.currentUser?.id;
      if (spUid != null && spUid.isNotEmpty) return spUid;
    } catch (_) {}
    try {
      final sessionUid = tryGetSupabaseClient()?.auth.currentSession?.user.id;
      if (sessionUid != null && sessionUid.isNotEmpty) return sessionUid;
    } catch (_) {}
    return null;
  }

  Future<void> _confirmSelection() async {
    final selectedRole = _selectedRole;
    if (selectedRole == null || _isSaving) return;

    setState(() => _isSaving = true);

    final customerType = selectedRole == 'enterprise'
        ? _corporateSubtype
        : (selectedRole == 'worker' ? 'Specialist' : 'Individual');

    final userId = _resolveCurrentUserId();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userModeStorageKey, selectedRole);
      LocalCacheService.instance.put(
        AppConstants.userModeStorageKey,
        selectedRole,
      );

      final client = tryGetSupabaseClient();
      if (client != null && userId != null) {
        if (selectedRole == 'customer' || selectedRole == 'enterprise') {
          await client.from(DatabaseTables.customerProfiles).upsert({
            'customer_id': userId,
            'customer_type': customerType,
            'company_name': selectedRole == 'enterprise' ? '' : null,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'customer_id');
        } else if (selectedRole == 'worker') {
          await client.from(DatabaseTables.workerProfiles).upsert({
            'worker_profile_id': userId,
            'title': 'Certified Technician',
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'worker_profile_id');
        }

        try {
          final roleRows = await client
              .from(DatabaseTables.roles)
              .select('role_id, role_name')
              .limit(20);
          final matched = (roleRows as List).firstWhere(
            (r) =>
                (r['role_name'] as String?)?.toLowerCase() ==
                (selectedRole == 'worker' ? 'worker' : 'customer'),
            orElse: () => null,
          );
          if (matched != null && matched['role_id'] != null) {
            await client.from(DatabaseTables.userRoles).upsert({
              'user_id': userId,
              'role_id': matched['role_id'],
              'is_active': true,
            }, onConflict: 'user_id,role_id');
          }
        } catch (_) {}

        await ProfileController.shared.loadProfile(userId);
      }
    } catch (_) {}

    if (!mounted) return;

    final targetMode = selectedRole;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.appShell,
      (route) => false,
      arguments: {'initialMode': targetMode},
    );
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
        actions: [
          TextButton.icon(
            onPressed: () => setState(() {
              AppLanguageService.toggleLanguage();
            }),
            icon: const Icon(Icons.language_rounded, size: 18),
            label: Text(
              isBn ? 'EN' : 'বাং',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn
                          ? 'আপনার মোড নির্বাচন করুন'
                          : 'Choose How You Use SKAVIA',
                      style: TextStyle(
                        fontFamily: AppTypography.headingFont,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isBn
                          ? 'একই অ্যাকাউন্টে আপনি যেকোনো সময় প্রোফাইল থেকে মোড বদলাতে পারবেন।'
                          : 'Unified account — switch between Personal, Business, and Specialist mode anytime from Profile.',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ..._roles.map((role) {
                      final roleId = role['id'] as String;
                      final isSelected = _selectedRole == roleId;
                      return RoleOptionCard(
                        role: role,
                        isSelected: isSelected,
                        corporateSubtype: _corporateSubtype,
                        onTap: () => setState(() => _selectedRole = roleId),
                        onSubtypeChanged: (sub) =>
                            setState(() => _corporateSubtype = sub),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
                    : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: AppButton(
                text: isBn ? 'চালিয়ে যান' : 'Continue',
                onPressed: _selectedRole != null && !_isSaving
                    ? _confirmSelection
                    : null,
                isLoading: _isSaving,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
