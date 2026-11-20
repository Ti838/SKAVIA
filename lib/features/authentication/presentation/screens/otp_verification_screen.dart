import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../navigation/data/repositories/dashboard_repository.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/otp_pin_input_row.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? fullName;
  final String? verificationId;

  const OtpVerificationScreen({
    super.key,
    this.phoneNumber,
    this.fullName,
    this.verificationId,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final int _pinLength = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  final AuthController _authController = AuthController();

  int _resendCountdown = 60;
  Timer? _countdownTimer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    if (widget.verificationId != null) {
      _authController.verificationId = widget.verificationId;
    }
    _controllers = List.generate(_pinLength, (_) => TextEditingController());
    _focusNodes = List.generate(_pinLength, (_) => FocusNode());
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _resendCountdown = 60;
      _canResend = false;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown > 1) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResend = true;
          _resendCountdown = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _authController.dispose();
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index) {
    final value = _controllers[index].text;
    if (value.length > 1) {
      final pasted = value.trim();
      for (int i = 0; i < _pinLength; i++) {
        if (i < pasted.length) {
          _controllers[i].text = pasted[i];
        }
      }
      _focusNodes.last.requestFocus();
      setState(() {});
      if (_currentOtp.length == _pinLength) {
        _handleVerify();
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < _pinLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_currentOtp.length == _pinLength) {
          _handleVerify();
        }
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
    setState(() {});
  }

  Future<void> _handleResend() async {
    if (!_canResend) return;
    final phone = widget.phoneNumber?.trim();
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Phone number is missing. Please go back and enter your phone number.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await _authController.sendPhoneOtp(phone);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code sent successfully.'),
          backgroundColor: AppColors.statusActive,
        ),
      );
      _startCountdown();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _authController.errorMessage ?? 'Failed to resend code.',
          ),
          backgroundColor: AppColors.statusCancelled,
        ),
      );
    }
  }

  Future<void> _handleVerify() async {
    final otp = _currentOtp;
    if (otp.length < _pinLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits.'),
          backgroundColor: AppColors.accentCoral,
        ),
      );
      return;
    }

    final success = await _authController.verifyPhoneOtp(
      otp,
      fullName: widget.fullName,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone verified successfully! Welcome to SKAVIA.'),
          backgroundColor: AppColors.statusActive,
        ),
      );
      final user = _authController.user;
      String? activeMode;
      if (user != null) {
        await ProfileController.shared.loadProfile(
          user.uid,
          fallbackEmail: user.email,
          fallbackName: user.displayName ?? widget.fullName,
          fallbackPhone: user.phoneNumber ?? widget.phoneNumber,
          fallbackAvatarUrl: user.photoURL,
        );
        final profile = await DashboardRepository().getUserProfileRecord(
          user.uid,
        );
        activeMode = profile?['active_mode']?.toString() ??
            LocalCacheService.instance
                .get('${AppConstants.userModeStorageKey}_${user.uid}')
                ?.toString() ??
            LocalCacheService.instance
                .get(AppConstants.userModeStorageKey)
                ?.toString();
      }
      if (!mounted) return;
      if (activeMode != null && activeMode.isNotEmpty) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.appShell,
          (route) => false,
          arguments: {'initialMode': activeMode},
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.roleSelection,
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _authController.errorMessage ?? 'Invalid verification code.',
          ),
          backgroundColor: AppColors.statusCancelled,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final skavia = context.skavia;
    final l10n = context.l10n;
    final isBn = context.isBengali;
    final displayPhone = (widget.phoneNumber?.trim().isNotEmpty ?? false)
        ? widget.phoneNumber!.trim()
        : (isBn ? 'আপনার নিবন্ধিত নম্বর' : 'your registered number');

    return Scaffold(
      backgroundColor: skavia.canvasBg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            AppAssets.emblem,
                            height: 24,
                            width: 24,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.engineering_rounded,
                              size: 20,
                              color: AppColors.primaryRoyal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.authOtpTitle,
                          style: TextStyle(
                            fontFamily: AppTypography.headingFont,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isBn
                              ? '$displayPhone নম্বরে ৬-সংখ্যার যাচাইকরণ কোড পাঠানো হয়েছে'
                              : 'We sent a 6-digit verification code to $displayPhone',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFont,
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: AppDimensions.roundedSheetTop,
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  children: [
                    Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        color: skavia.softPeachBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sms_rounded,
                        size: 36,
                        color: AppColors.accentCoral,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.authOtpTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.headingFont,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.authOtpSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFont,
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),

                    OtpPinInputRow(
                      pinLength: _pinLength,
                      controllers: _controllers,
                      focusNodes: _focusNodes,
                      onDigitChanged: _onDigitChanged,
                    ),

                    const SizedBox(height: 32),

                    ListenableBuilder(
                      listenable: _authController,
                      builder: (context, _) {
                        return AppButton(
                          text: l10n.authVerifyCode,
                          isLoading: _authController.isLoading,
                          onPressed: _handleVerify,
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.authResendCode,
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFont,
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: _canResend ? _handleResend : null,
                          child: Text(
                            _canResend
                                ? (context.isBengali ? 'এখনই পাঠান' : 'Resend Now')
                                : '${_resendCountdown}s',
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFont,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _canResend
                                  ? skavia.brandAccent
                                  : colorScheme.onSurfaceVariant.withValues(
                                      alpha: 0.6,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
