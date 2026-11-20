import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/validators.dart';
import '../../../navigation/data/repositories/dashboard_repository.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_header_widget.dart';
import '../widgets/auth_terms_checkbox.dart';
import '../widgets/registration_form_fields.dart';
import '../widgets/social_auth_buttons_row.dart';

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
      _termsError = _agreeToTerms
          ? null
          : 'You must accept the Terms of Service & Privacy Policy';
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
          content: Text(
            'Account created successfully! Choose your account mode.',
          ),
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
        );
      }

      if (user != null) {
        try {
          final summary = await DashboardRepository().getAuthorizedRoles(
            user.uid,
          );
          if (mounted &&
              (summary.hasCustomer ||
                  summary.hasEnterprise ||
                  summary.hasWorker)) {
            final activeMode = summary.hasWorker
                ? 'worker'
                : (summary.hasEnterprise ? 'enterprise' : 'customer');
            LocalCacheService.instance.put(
              AppConstants.userModeStorageKey,
              activeMode,
            );
            if (!mounted) return;
            Navigator.of(context).pushReplacementNamed(
              AppRoutes.appShell,
              arguments: {'initialMode': activeMode},
            );
            return;
          }
        } catch (_) {}

        final activeMode = LocalCacheService.instance
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final skavia = context.skavia;
    final l10n = context.l10n;
    final isBn = context.isBengali;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
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
                                color: colorScheme.error.withValues(
                                  alpha: 0.35,
                                ),
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

                    RegistrationFormFields(
                      fullNameController: _fullNameController,
                      emailController: _emailController,
                      phoneController: _phoneController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                    ),

                    const SizedBox(height: 18),

                    AuthTermsCheckbox(
                      value: _agreeToTerms,
                      errorText: _termsError,
                      onChanged: (val) {
                        setState(() {
                          _agreeToTerms = val;
                          if (_agreeToTerms) _termsError = null;
                        });
                      },
                    ),

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

                    SocialAuthButtonsRow(onGoogleSignIn: _handleGoogleSignUp),

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
                            Navigator.of(context)
                                .pushReplacementNamed(AppRoutes.login);
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
