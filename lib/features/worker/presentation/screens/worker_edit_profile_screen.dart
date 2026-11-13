import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/skavia_brand_image.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/datasources/worker_profile_remote_datasource.dart';
import '../widgets/worker_verification_section.dart';

class WorkerEditProfileScreen extends StatefulWidget {
  const WorkerEditProfileScreen({super.key});

  @override
  State<WorkerEditProfileScreen> createState() =>
      _WorkerEditProfileScreenState();
}

class _WorkerEditProfileScreenState extends State<WorkerEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final WorkerProfileRemoteDataSource _dataSource =
      WorkerProfileRemoteDataSource();
  final _titleController = TextEditingController(
    text: 'Certified Electrician & HVAC Specialist',
  );
  final _rateController = TextEditingController(text: '650');
  final _bioController = TextEditingController(
    text:
        'Experienced technician with 5+ years servicing residential, corporate, and industrial electrical boards, AC cooling systems, and backup generators across Dhaka.',
  );
  final AuthController _authController = AuthController();

  String _workingArea = 'All Dhaka City';
  String _verificationStatus = 'Pending';
  bool _isAvailable = true;
  bool _isLoading = false;
  bool _nidUploaded = true;
  bool _certUploaded = true;

  final List<String> _workingZones = [
    'All Dhaka City',
    'Gulshan, Banani & Baridhara',
    'Dhanmondi & Lalmatia',
    'Uttara & Airport Zone',
    'Mirpur & Pallabi',
    'Motijheel & Old Dhaka',
  ];

  @override
  void initState() {
    super.initState();
    _loadCachedDraft();
    _fetchWorkerProfile();
  }

  void _loadCachedDraft() {
    final draft = _dataSource.loadCachedDraft();
    if (draft == null) return;
    if (draft['title'] is String) {
      _titleController.text = draft['title'] as String;
    }
    if (draft['rate'] != null) {
      _rateController.text = draft['rate'].toString();
    }
    if (draft['bio'] is String) _bioController.text = draft['bio'] as String;
    if (draft['workingArea'] is String &&
        _workingZones.contains(draft['workingArea'])) {
      _workingArea = draft['workingArea'] as String;
    }
    if (draft['isAvailable'] is bool) {
      _isAvailable = draft['isAvailable'] as bool;
    }
    if (draft['nidUploaded'] is bool) {
      _nidUploaded = draft['nidUploaded'] as bool;
    }
    if (draft['certUploaded'] is bool) {
      _certUploaded = draft['certUploaded'] as bool;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _rateController.dispose();
    _bioController.dispose();
    _authController.dispose();
    super.dispose();
  }

  Future<void> _fetchWorkerProfile() async {
    final user = _authController.user;
    if (user == null) return;

    final response = await _dataSource.fetchWorkerProfile(user.uid);
    if (response != null && mounted) {
      setState(() {
        _titleController.text = response['title'] ?? _titleController.text;
        _rateController.text = (response['expected_rate'] ?? 650).toString();
        _bioController.text = response['bio'] ?? _bioController.text;
        final area = response['working_area']?.toString();
        if (area != null && _workingZones.contains(area)) {
          _workingArea = area;
        }
        _verificationStatus =
            response['verification_status'] ?? _verificationStatus;
        _isAvailable = response['is_available'] ?? true;
      });
    }
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _authController.user;
      final rate = double.tryParse(_rateController.text.trim()) ?? 650.0;

      await _dataSource.saveWorkerProfile(
        userId: user?.uid,
        title: _titleController.text.trim(),
        expectedRate: rate,
        workingArea: _workingArea,
        bio: _bioController.text.trim(),
        isAvailable: _isAvailable,
        nidUploaded: _nidUploaded,
        certUploaded: _certUploaded,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Worker profile updated successfully!'),
          backgroundColor: AppColors.statusActive,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return Scaffold(
      backgroundColor: tokens.canvasBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Worker Profile',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.headingFont,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: tokens.cardBg,
                      shape: BoxShape.circle,
                    ),
                    child: SkaviaBrandImage(
                      assetPath: AppAssets.emblem,
                      height: 22,
                      width: 22,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.engineering_rounded,
                        size: 18,
                        color: tokens.brandAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Curved 32dp Sheet Form Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: tokens.sheetBg,
                  borderRadius: AppDimensions.roundedSheetTop,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WorkerVerificationBanner(
                          verificationStatus: _verificationStatus,
                        ),
                        const SizedBox(height: 20),

                        // Availability Toggle Switch
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: tokens.subtleCardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: tokens.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Active Dispatch Status',
                                      style: TextStyle(
                                        fontFamily: AppTypography.headingFont,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      _isAvailable
                                          ? 'Ready for immediate job alerts'
                                          : 'Currently off-duty',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: tokens.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Switch.adaptive(
                                value: _isAvailable,
                                activeTrackColor: tokens.brandAccent,
                                onChanged: (val) =>
                                    setState(() => _isAvailable = val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        AppTextField(
                          controller: _titleController,
                          label: 'Trade Specialization / Title',
                          hint: 'e.g. Master Electrician, Senior Plumber',
                          validator: (val) =>
                              (val == null || val.trim().isEmpty)
                              ? 'Please enter your title'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Expected Rate & Working Zone
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final stackVertically =
                                constraints.maxWidth < 330 || textScale > 1.3;

                            final rateField = AppTextField(
                              controller: _rateController,
                              label: 'Rate (৳/Hour)',
                              hint: '650',
                              keyboardType: TextInputType.number,
                              prefixIcon: Icon(
                                Icons.sell_outlined,
                                color: tokens.brandAccent,
                                size: 20,
                              ),
                            );

                            final zoneField = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Working Zone',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: tokens.secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tokens.inputBg,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: tokens.border),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _workingArea,
                                      isExpanded: true,
                                      dropdownColor: tokens.cardBg,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                      items: _workingZones.map((z) {
                                        return DropdownMenuItem<String>(
                                          value: z,
                                          child: Text(
                                            z,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _workingArea = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );

                            if (stackVertically) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  rateField,
                                  const SizedBox(height: 14),
                                  zoneField,
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(flex: 3, child: rateField),
                                const SizedBox(width: 12),
                                Expanded(flex: 4, child: zoneField),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        AppTextField(
                          controller: _bioController,
                          label: 'Professional Summary & Experience',
                          hint:
                              'Describe your certifications, experience, and past commercial/home repairs...',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),

                        WorkerDocumentUploadSection(
                          nidUploaded: _nidUploaded,
                          onToggleNid: () {
                            setState(() => _nidUploaded = !_nidUploaded);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _nidUploaded
                                      ? 'NID document status marked for verification sync.'
                                      : 'NID verification status cleared.',
                                ),
                              ),
                            );
                          },
                          certUploaded: _certUploaded,
                          onToggleCert: () {
                            setState(() => _certUploaded = !_certUploaded);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _certUploaded
                                      ? 'Trade certification status marked for verification sync.'
                                      : 'Trade certification status cleared.',
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        AppButton(
                          text: _isLoading
                              ? 'Saving...'
                              : 'Save Profile Changes',
                          isLoading: _isLoading,
                          onPressed: _handleSaveProfile,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
