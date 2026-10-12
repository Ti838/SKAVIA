import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_header_widget.dart';
import '../widgets/forgot_password_modal_sheet.dart';
import '../widgets/login_method_toggle.dart';
import '../widgets/social_auth_buttons_row.dart';

/// World-Class Enterprise Sign In Screen for SKAVIA.
/// - Aligned with SKAVIA SRS Section 3.1.A (FR-A03, FR-A05)
/// - Visual styling matching approved reference theme (Sky Blue, 32dp sheet, pill elements)
/// - Dual Login Modes: Email/Password & Phone Number OTP
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  final AuthController _authController = AuthController();
  int _selectedMethodIndex = 0; // 0 = Email, 1 = Phone OTP
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _authController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await _authController.loginWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.appShell);
    }
  }

  Future<void> _handlePhoneOtpSend() async {
    final rawPhone = _phoneController.text.trim();
    if (rawPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await _authController.sendPhoneOtp(rawPhone);
    if (success && mounted) {
      Navigator.of(context).pushNamed(
        AppRoutes.otpVerification,
        arguments: {'phone': rawPhone, 'isLogin': true},
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final success = await _authController.signInWithGoogle();
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.appShell);
    }
  }

  void _showForgotPasswordModal() {
    ForgotPasswordModalSheet.show(
      context,
      initialEmail: _emailController.text.trim(),
      authController: _authController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    // Header Logo & Greeting
                    const AuthHeaderWidget(
                      title: 'Welcome Back',
                      subtitle: 'Sign in to continue to SKAVIA',
                    ),
                    const SizedBox(height: 24),

                    // Login Mode Toggle (Email / Phone)
                    LoginMethodToggle(
                      selectedIndex: _selectedMethodIndex,
                      onMethodSelected: (idx) =>
                          setState(() => _selectedMethodIndex = idx),
                    ),
                    const SizedBox(height: 18),

                    // Error Banner if exists
                    ListenableBuilder(
                      listenable: _authController,
                      builder: (context, _) {
                        if (_authController.errorMessage != null) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _authController.errorMessage!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.error,
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

                    if (_selectedMethodIndex == 0) ...[
                      // Email Field
                      AppTextField(
                        controller: _emailController,
                        label: 'Email or Phone',
                        hint: 'name@example.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.mail_outline_rounded,
                          color: AppColors.textMedium,
                          size: 20,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!val.contains('@')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      AppTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: '••••••••',
                        isPassword: true,
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.textMedium,
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
                      const SizedBox(height: 12),

                      // Remember Me & Forgot Password Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v ?? true),
                                  activeColor: AppColors.primarySky,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Remember me',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textMedium,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _showForgotPasswordModal,
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primarySky,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Primary Blue Sign In Pill Button
                      ListenableBuilder(
                        listenable: _authController,
                        builder: (context, _) {
                          return SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _authController.isLoading
                                  ? null
                                  : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primarySky,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppDimensions.roundedPill,
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
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      // Phone Number Field
                      AppTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: '+880 1700-000000',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(
                          Icons.phone_iphone_rounded,
                          color: AppColors.textMedium,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'A 6-digit OTP code will be sent to your mobile phone via SMS.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      ListenableBuilder(
                        listenable: _authController,
                        builder: (context, _) {
                          return SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _authController.isLoading
                                  ? null
                                  : _handlePhoneOtpSend,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primarySky,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppDimensions.roundedPill,
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
                                  : const Text(
                                      'Send Verification Code',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Social Sign In (Google & GitHub)
                    SocialAuthButtonsRow(onGoogleSignIn: _handleGoogleSignIn),

                    const SizedBox(height: 32),

                    // Don't have an account? Sign Up footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMedium,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushReplacementNamed(AppRoutes.register);
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primarySky,
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
