import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/validators.dart';
import '../../../navigation/data/repositories/dashboard_repository.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_header_widget.dart';
import '../widgets/email_login_form.dart';
import '../widgets/forgot_password_modal_sheet.dart';
import '../widgets/login_method_toggle.dart';
import '../widgets/phone_login_form.dart';
import '../widgets/social_auth_buttons_row.dart';

/// Enterprise Sign In Screen for SKAVIA supporting Email/Password, Phone OTP,
/// Google Sign-In, and persisted Remember Me preferences.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _rememberedEmailKey = 'remembered_email';
  static const String _rememberMeEnabledKey = 'remember_me_enabled';

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  final AuthController _authController = AuthController();
  final SecureStorageService _secureStorage = SecureStorageService();
  int _selectedMethodIndex = 0; // 0 = Email, 1 = Phone OTP
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _restoreRememberedCredentials();
  }

  Future<void> _restoreRememberedCredentials() async {
    final rememberFlag = await _secureStorage.read(key: _rememberMeEnabledKey);
    final savedEmail = await _secureStorage.read(key: _rememberedEmailKey);
    if (!mounted) return;
    setState(() {
      if (rememberFlag != null) {
        _rememberMe = rememberFlag != 'false';
      }
      if (_rememberMe && savedEmail != null && savedEmail.isNotEmpty) {
        _emailController.text = savedEmail;
      }
    });
  }

  Future<void> _persistRememberMe(String email) async {
    await _secureStorage.write(
      key: _rememberMeEnabledKey,
      value: _rememberMe ? 'true' : 'false',
    );
    if (_rememberMe && email.isNotEmpty) {
      await _secureStorage.write(key: _rememberedEmailKey, value: email);
    } else {
      await _secureStorage.delete(key: _rememberedEmailKey);
    }
  }

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
    final trimmedEmail = _emailController.text.trim();
    final success = await _authController.loginWithEmail(
      email: trimmedEmail,
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      await _persistRememberMe(trimmedEmail);
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
    if (!_formKey.currentState!.validate()) return;
    final rawPhone = _phoneController.text.trim();
    final phoneError = Validators.bdPhone(rawPhone);
    if (phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(phoneError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final formattedPhone = Validators.normalizeBdPhone(rawPhone);
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
                    // Header Logo & Greeting
                    const AuthHeaderWidget(
                      title: 'Welcome Back',
                      subtitle: 'Sign in to continue to SKAVIA',
                    ),
                    const SizedBox(height: 24),

                    // Login Mode Toggle (Email / Phone)
                    LoginMethodToggle(
                      selectedIndex: _selectedMethodIndex,
                      onMethodSelected: (idx) => setState(() {
                        _selectedMethodIndex = idx;
                        _authController.clearError();
                      }),
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

                    if (_selectedMethodIndex == 0)
                      EmailLoginForm(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        rememberMe: _rememberMe,
                        onRememberMeChanged: (v) async {
                          setState(() => _rememberMe = v);
                          await _persistRememberMe(
                            _emailController.text.trim(),
                          );
                        },
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

                    // Don't have an account? Sign Up footer (Wrap prevents 320dp + 2.0x overflow)
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacementNamed(
                              AppRoutes.register,
                            );
                          },
                          child: Text(
                            'Sign Up',
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
