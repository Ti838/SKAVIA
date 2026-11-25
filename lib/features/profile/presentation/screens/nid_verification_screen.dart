import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/datasources/nid_verification_remote_datasource.dart';
import '../../data/models/nid_verification_status_model.dart';
import '../controllers/profile_controller.dart';

/// Screen allowing any citizen member or specialist to submit and inspect
/// their Bangladesh National ID (NID) compliance status.
class NidVerificationScreen extends StatefulWidget {
  final ProfileController? controller;

  const NidVerificationScreen({super.key, this.controller});

  @override
  State<NidVerificationScreen> createState() => _NidVerificationScreenState();
}

class _NidVerificationScreenState extends State<NidVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nidController = TextEditingController();
  final _dobController = TextEditingController();
  final _datasource = NidVerificationRemoteDataSource();

  NidVerificationStatusModel? _statusModel;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isResubmitting = false;

  bool _frontPhotoAttached = false;
  bool _backPhotoAttached = false;

  ProfileController get _effectiveController =>
      widget.controller ?? ProfileController.shared;

  @override
  void initState() {
    super.initState();
    _loadInitialStatus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nidController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialStatus() async {
    final profile = _effectiveController.profile;
    final userId = profile?.id ?? '';

    if (profile != null && profile.fullName != 'SKAVIA Member') {
      _nameController.text = profile.fullName;
    }
    if (profile?.dateOfBirth != null) {
      _dobController.text = profile!.dateOfBirth!.toIso8601String().split('T')[0];
    }

    if (userId.isNotEmpty) {
      final status = await _datasource.fetchStatus(userId);
      if (mounted) {
        setState(() {
          _statusModel = status;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 24, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 14),
      helpText: 'Select Date of Birth (as on NID)',
    );
    if (picked != null) {
      setState(() {
        _dobController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_frontPhotoAttached || !_backPhotoAttached) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please attach both front and back photographs of your National ID card.',
          ),
          backgroundColor: AppColors.accentCoral,
        ),
      );
      return;
    }

    final userId = _effectiveController.profile?.id ?? '';
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to submit your NID verification.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final cleanNid = _nidController.text.replaceAll(RegExp(r'\D'), '');

    final success = await _datasource.submitVerification(
      userId: userId,
      nidNumber: cleanNid,
      fullName: _nameController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
      frontImageUrl: 'https://skavia-bd.vercel.app/images/nid-front-sample.png',
      backImageUrl: 'https://skavia-bd.vercel.app/images/nid-back-sample.png',
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'National ID submitted successfully. Our trust & safety team will review your verification.',
          ),
          backgroundColor: AppColors.statusActive,
        ),
      );
      _loadInitialStatus();
      setState(() => _isResubmitting = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to submit verification. Please check network connection and try again.',
          ),
          backgroundColor: AppColors.statusCancelled,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = context.isBengali;

    final currentStatus = _statusModel?.status ?? NidStatus.unverified;
    final showForm = (currentStatus == NidStatus.unverified) ||
        (currentStatus == NidStatus.rejected && _isResubmitting);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppAppBar(
        title: isBn
            ? 'জাতীয় পরিচয়পত্র যাচাইকরণ'
            : 'National ID (NID) Verification',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Status Overview Banner
                  _buildStatusOverviewBanner(context, currentStatus, isBn),
                  const SizedBox(height: 20),

                  // 2. Either Form OR Status Details
                  if (showForm)
                    _buildVerificationForm(context, isBn)
                  else
                    _buildStatusDetails(context, currentStatus, isBn),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusOverviewBanner(
    BuildContext context,
    NidStatus status,
    bool isBn,
  ) {
    final tokens = context.skavia;
    final colorScheme = Theme.of(context).colorScheme;

    final (color, icon, title, desc) = switch (status) {
      NidStatus.verified => (
        AppColors.successGreen,
        Icons.verified_rounded,
        isBn ? 'এনআইডি সফলভাবে যাচাইকৃত' : 'National ID Verified',
        isBn
            ? 'আপনার প্রোফাইলে অফিসিয়াল ভেরিফাইড ব্যাজ সক্রিয় রয়েছে।'
            : 'Your account is officially verified with government-issued NID.',
      ),
      NidStatus.pending => (
        AppColors.warningAmber,
        Icons.hourglass_top_rounded,
        isBn ? 'ভেরিফিকেশন পর্যালোচনায় রয়েছে' : 'Verification Under Review',
        isBn
            ? 'আমাদের ট্রাস্ট অ্যান্ড সেফটি টিম আপনার ডকুমেন্ট পরীক্ষা করছে।'
            : 'Your submitted NID documents are currently being checked by our compliance desk.',
      ),
      NidStatus.rejected => (
        AppColors.errorRed,
        Icons.error_outline_rounded,
        isBn ? 'ভেরিফিকেশন বাতিল হয়েছে' : 'Verification Action Needed',
        isBn
            ? 'তথ্য বা ডকুমেন্টে সমস্যা ছিল। অনুগ্রহ করে সঠিক তথ্যসহ পুনরায় সাবমিট করুন।'
            : 'Review feedback was provided. Please inspect the remarks and resubmit valid NID.',
      ),
      NidStatus.unverified => (
        AppColors.primaryRoyal,
        Icons.shield_outlined,
        isBn ? 'এনআইডি যাচাই সম্পন্ন করুন' : 'Verify Your Identity',
        isBn
            ? 'স্মার্ট এনআইডি যাচাই করে প্রোফাইলে ট্রাস্ট ব্যাজ ও নিরাপদ সেবা নিশ্চিত করুন।'
            : 'Submit your Smart NID to unlock the official Verified Shield badge across SKAVIA.',
      ),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.headingFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: tokens.secondaryText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDetails(
    BuildContext context,
    NidStatus status,
    bool isBn,
  ) {
    final tokens = context.skavia;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBn ? 'যাচাইকরণ বিবরণ' : 'Verification Record Details',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            isBn ? 'এনআইডি নম্বর' : 'National ID Number',
            _statusModel?.maskedNid ?? '••••••••••',
            tokens,
            colorScheme,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            isBn ? 'নাম (এনআইডি অনুযায়ী)' : 'Full Name (as on NID)',
            _statusModel?.fullName ?? _effectiveController.profile?.fullName ?? 'Citizen Member',
            tokens,
            colorScheme,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            isBn ? 'সাবমিট করার তারিখ' : 'Submitted On',
            _statusModel?.submittedAt != null
                ? '${_statusModel!.submittedAt!.year}-${_statusModel!.submittedAt!.month.toString().padLeft(2, '0')}-${_statusModel!.submittedAt!.day.toString().padLeft(2, '0')}'
                : 'Recent',
            tokens,
            colorScheme,
          ),
          if (_statusModel?.reviewNotes != null && _statusModel!.reviewNotes!.isNotEmpty) ...[
            const Divider(height: 24),
            Text(
              isBn ? 'কমপ্লায়েন্স নোট / পর্যালোচনা' : 'Compliance Review Remarks',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: tokens.mutedText,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tokens.subtleCardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tokens.border),
              ),
              child: Text(
                _statusModel!.reviewNotes!,
                style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (status == NidStatus.pending)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadInitialStatus();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(isBn ? 'স্ট্যাটাস রিফ্রেশ করুন' : 'Refresh Verification Status'),
              ),
            )
          else if (status == NidStatus.rejected)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() => _isResubmitting = true);
                },
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: Text(isBn ? 'পুনরায় এনআইডি সাবমিট করুন' : 'Resubmit Valid NID'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, dynamic tokens, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: tokens.secondaryText),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationForm(
    BuildContext context,
    bool isBn,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name Field
          AppTextField(
            controller: _nameController,
            label: isBn ? 'পূর্ণ নাম (এনআইডি অনুযায়ী)' : 'Full Name (as printed on NID)',
            hint: 'e.g. Mohammad Abdullah',
            validator: (v) {
              if (v == null || v.trim().length < 3) {
                return 'Please enter your full legal name as on your NID card';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // NID Number Field
          AppTextField(
            controller: _nidController,
            label: isBn ? 'জাতীয় পরিচয়পত্র নম্বর (১০ বা ১৭ ডিজিট)' : 'NID Card Number (10 or 17 digits)',
            hint: 'e.g. 19942692512000342',
            keyboardType: TextInputType.number,
            validator: (v) {
              final clean = (v ?? '').replaceAll(RegExp(r'\D'), '');
              if (clean.length != 10 && clean.length != 13 && clean.length != 17) {
                return 'Enter valid 10-digit Smart NID or 17-digit Classic NID';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Date of Birth Field
          InkWell(
            onTap: _pickDateOfBirth,
            child: IgnorePointer(
              child: AppTextField(
                controller: _dobController,
                label: isBn ? 'জন্ম তারিখ (এনআইডি অনুযায়ী)' : 'Date of Birth (as on NID)',
                hint: 'YYYY-MM-DD',
                prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter or select your date of birth';
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Photo Upload Strip (Front and Back)
          Text(
            isBn ? 'এনআইডি কার্ডের ছবি সংযুক্ত করুন' : 'Attach NID Card Photographs',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDocUploadCard(
                  title: isBn ? 'এনআইডি সামনের দিক' : 'NID Front Side',
                  isAttached: _frontPhotoAttached,
                  onTap: () {
                    setState(() => _frontPhotoAttached = !_frontPhotoAttached);
                  },
                  tokens: tokens,
                  colorScheme: colorScheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDocUploadCard(
                  title: isBn ? 'এনআইডি পেছনের দিক' : 'NID Back Side',
                  isAttached: _backPhotoAttached,
                  onTap: () {
                    setState(() => _backPhotoAttached = !_backPhotoAttached);
                  },
                  tokens: tokens,
                  colorScheme: colorScheme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Privacy Assurance Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: tokens.subtleCardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: tokens.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 20,
                  color: AppColors.successGreen,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isBn
                        ? 'আপনার এনআইডি তথ্য সম্পূর্ণ সুরক্ষিত ও এনক্রিপ্টেড। এটি শুধুমাত্র নিরাপত্তা যাচাইয়ের জন্য ব্যবহৃত হয়।'
                        : 'Your NID details are strictly encrypted and used solely for trust and identity compliance.',
                    style: TextStyle(fontSize: 11.5, color: tokens.secondaryText, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          AppButton(
            text: isBn ? 'ভেরিফিকেশনের জন্য জমা দিন' : 'Submit for Verification',
            isLoading: _isSubmitting,
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }

  Widget _buildDocUploadCard({
    required String title,
    required bool isAttached,
    required VoidCallback onTap,
    required dynamic tokens,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: isAttached ? AppColors.successGreen.withValues(alpha: 0.08) : tokens.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAttached ? AppColors.successGreen : tokens.border,
            width: isAttached ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isAttached ? Icons.check_circle_rounded : Icons.add_a_photo_outlined,
              color: isAttached ? AppColors.successGreen : tokens.brandAccent,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isAttached ? AppColors.successGreen : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isAttached ? 'Attached ✓' : 'Tap to capture',
              style: TextStyle(
                fontSize: 11,
                color: isAttached ? AppColors.successGreen : tokens.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
