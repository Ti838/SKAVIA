import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../navigation/data/repositories/dashboard_repository.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_header_widget.dart';
import '../widgets/email_login_form.dart';
import '../widgets/forgot_password_modal_sheet.dart';
import '../widgets/login_method_toggle.dart';
import '../widgets/phone_login_form.dart';
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
    if (!mounted) return;
    if (success) {
      await _navigateToAppropriateScreen();
    } else if (_authController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authController.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
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

    // Ensure phone number has country code prefix
    final formattedPhone = rawPhone.startsWith('+') ? rawPhone : '+88$rawPhone';

    final success = await _authController.sendPhoneOtp(formattedPhone);
    if (success && mounted) {
      Navigator.of(context).pushNamed(
        AppRoutes.otpVerification,
        arguments: {
          'phoneNumber': formattedPhone,
          'verificationId': _authController.verificationId,
          'isLogin': true,
        },
      );
    } else if (mounted && _authController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authController.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final success = await _authController.signInWithGoogle();
    if (!mounted) return;
    if (success) {
      await _navigateToAppropriateScreen();
    } else if (_authController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authController.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _navigateToAppropriateScreen() async {
    final user = _authController.user;
    if (user != null) {
      final profile =
          await DashboardRepository().getUserProfileRecord(user.uid);
      final activeMode = profile?['active_mode']?.toString();
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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

                    if (_selectedMethodIndex == 0)
                      EmailLoginForm(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        rememberMe: _rememberMe,
                        onRememberMeChanged: (v) =>
                            setState(() => _rememberMe = v),
                        onForgotPassword: _showForgotPasswordModal,
                        authController: _authController,
                        onLogin: _handleLogin,
                      )
                    else
                      PhoneLoginForm(
                        phoneController: _phoneController,
                        authController: _authController,
                        onSendOtp: _handlePhoneOtpSend,
                      ),

                    const SizedBox(height: 24),

                    // Sign In (Google)
                    SocialAuthButtonsRow(onGoogleSignIn: _handleGoogleSignIn),

                    const SizedBox(height: 32),

                    // Don't have an account? Sign Up footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
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
