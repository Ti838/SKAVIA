import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/motion/sakuga_checkbox.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../navigation/data/repositories/dashboard_repository.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_header_widget.dart';

/// Single unified minimal registration screen for SKAVIA.
/// Preserves fast 5-field signup (`Full Name`, `Email`, `Phone`, `Password`, `Confirm Password`),
/// legal consent verification, official Google Sign-Up, and role selection routing.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authController = AuthController();

  bool _agreeToTerms = false;
  String? _termsError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _authController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() {
      _termsError = _agreeToTerms ? null : 'You must accept the Terms of Service & Privacy Policy';
    });

    if (!_formKey.currentState!.validate() || !_agreeToTerms) return;

    final formattedPhone = Validators.normalizeBdPhone(
      _phoneController.text.trim(),
    );

    final success = await _authController.register(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: formattedPhone,
      primaryRole: 'Individual Customer',
    );

    if (success && mounted) {
      final user = _authController.user;
      if (user != null) {
        await ProfileController.shared.loadProfile(
          user.uid,
          fallbackEmail: _emailController.text.trim(),
          fallbackName: _fullNameController.text.trim(),
          fallbackPhone: formattedPhone,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Choose your account mode.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pushReplacementNamed(AppRoutes.roleSelection);
    } else if (mounted && _authController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authController.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignUp() async {
    final success = await _authController.signInWithGoogle();
    if (!mounted) return;

    if (success) {
      final user = _authController.user;
      if (user != null) {
        await ProfileController.shared.loadProfile(
          user.uid,
          fallbackEmail: user.email,
          fallbackName: user.displayName,
          fallbackPhone: user.phoneNumber,
          fallbackAvatarUrl: user.photoURL,
        );

        final profile = await DashboardRepository().getUserProfileRecord(
          user.uid,
        );
        final activeMode = profile?['active_mode']?.toString() ??
            LocalCacheService.instance
                .get('${AppConstants.userModeStorageKey}_${user.uid}')
                ?.toString() ??
            LocalCacheService.instance
                .get(AppConstants.userModeStorageKey)
                ?.toString();

        if (activeMode != null && activeMode.isNotEmpty && mounted) {
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.appShell,
            arguments: {'initialMode': activeMode},
          );
          return;
        }
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.roleSelection);
      }
    } else if (_authController.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authController.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showLegalDialog(String title, String content) {
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
    final skavia = context.skavia;
    final l10n = context.l10n;
    final isBn = context.isBengali;

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                24,
                20,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AuthHeaderWidget(
                      title: l10n.authSignUp,
                      subtitle: isBn
                          ? 'SKAVIA-তে যোগ দিন এবং সহজে শুরু করুন'
                          : 'Join SKAVIA and get started',
                    ),
                    const SizedBox(height: 24),

                    // Error Banner if exists
                    ListenableBuilder(
                      listenable: _authController,
                      builder: (context, _) {
                        if (_authController.errorMessage != null) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: colorScheme.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.error.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: colorScheme.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _authController.errorMessage!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    AppTextField(
                      controller: _fullNameController,
                      label: l10n.authFullName,
                      hint: l10n.authFullNameHint,
                      prefixIcon: Icon(
                        Icons.badge_outlined,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().length < 3) {
                          return isBn
                              ? 'সম্পূর্ণ নাম কমপক্ষে ৩ অক্ষরের হতে হবে'
                              : 'Full name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    AppTextField(
                      controller: _emailController,
                      label: l10n.authEmail,
                      hint: l10n.authEmailHint,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(
                        Icons.alternate_email_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 14),

                    AppTextField(
                      controller: _phoneController,
                      label: l10n.authPhone,
                      hint: l10n.authPhoneHint,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icon(
                        Icons.phone_iphone_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      validator: Validators.bdPhone,
                    ),
                    const SizedBox(height: 14),

                    AppTextField(
                      controller: _passwordController,
                      label: l10n.authPassword,
                      hint: '••••••••',
                      isPassword: true,
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return isBn
                              ? 'পাসওয়ার্ড আবশ্যক'
                              : 'Password is required';
                        }
                        if (val.length < 6) {
                          return isBn
                              ? 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে'
                              : 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    AppTextField(
                      controller: _confirmPasswordController,
                      label: l10n.authConfirmPassword,
                      hint: '••••••••',
                      isPassword: true,
                      prefixIcon: Icon(
                        Icons.lock_reset_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      validator: (val) {
                        if (val != _passwordController.text) {
                          return isBn
                              ? 'পাসওয়ার্ড দুটি মিলছে না'
                              : 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Terms & Privacy Acceptance Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SakugaCheckbox(
                          value: _agreeToTerms,
                          semanticLabel: isBn
                              ? 'শর্তাবলী ও গোপনীয়তা নীতি স্বীকার করুন'
                              : 'Agree to Terms and Privacy Policy',
                          activeColor: const Color(0xFF003399),
                          onChanged: (val) {
                            setState(() {
                              _agreeToTerms = val;
                              if (_agreeToTerms) _termsError = null;
                            });
                          },
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
                    if (_termsError != null) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _termsError!,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Submit Button: Create Account
                    ListenableBuilder(
                      listenable: _authController,
                      builder: (context, _) {
                        return ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 52),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _authController.isLoading
                                  ? null
                                  : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 16,
                                ),
                                backgroundColor: const Color(0xFF003399),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _authController.isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      l10n.authSignUp,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Divider: OR CONTINUE WITH
                    Row(
                      children: [
                        Expanded(child: Divider(color: borderColor)),
                        Flexible(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              l10n.authOrContinueWith,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: borderColor)),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Official Google Sign-Up Full-Width Button
                    ListenableBuilder(
                      listenable: _authController,
                      builder: (context, _) {
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _authController.isLoading
                                ? null
                                : _handleGoogleSignUp,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isDark
                                  ? colorScheme.surfaceContainerHighest
                                  : Colors.white,
                              foregroundColor: colorScheme.onSurface,
                              side: BorderSide(color: borderColor, width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppAssets.googleLogo,
                                  height: 20,
                                  width: 20,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.g_mobiledata_rounded,
                                    color: Color(0xFFEA4335),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    isBn
                                        ? 'Google দিয়ে সাইন আপ করুন'
                                        : 'Sign up with Google',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // Already have an account? Sign In footer
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        Text(
                          l10n.authHaveAccount,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacementNamed(
                              AppRoutes.login,
                            );
                          },
                          child: Text(
                            l10n.authSignIn,
                            style: TextStyle(
                              fontSize: 13,
                              color: skavia.brandAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
