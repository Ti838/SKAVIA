import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_header_widget.dart';

/// Single unified minimal registration screen for SKAVIA.
/// Preserves fast 5-field signup (`Full Name`, `Email`, `Phone`, `Password`, `Confirm`)
/// followed by deliberate workspace/role selection and progressive eligibility gating.
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
    if (!_formKey.currentState!.validate()) return;

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final skavia = context.skavia;

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
                    const AuthHeaderWidget(
                      title: 'Create Your Account',
                      subtitle: 'Join SKAVIA and get started',
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
                      label: 'Full Name',
                      hint: 'Your Full Name',
                      prefixIcon: Icon(
                        Icons.badge_outlined,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().length < 3) {
                          return 'Full name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    AppTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'name@example.com',
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
                      label: 'Phone Number',
                      hint: '01700-000000',
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
                      label: 'Password',
                      hint: '••••••••',
                      isPassword: true,
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Password is required';
                        }
                        if (val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    AppTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: '••••••••',
                      isPassword: true,
                      prefixIcon: Icon(
                        Icons.lock_reset_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      validator: (val) {
                        if (val != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Pill Button
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
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                elevation: 0,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppDimensions.roundedPill,
                                ),
                              ),
                              child: _authController.isLoading
                                  ? SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          colorScheme.onPrimary,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'Create Account',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        Text(
                          'Already have an account?',
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
                            'Login',
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
