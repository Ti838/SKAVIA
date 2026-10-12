import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../data/tables/database_tables.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../widgets/worker_verification_section.dart';

class WorkerEditProfileScreen extends StatefulWidget {
  const WorkerEditProfileScreen({super.key});

  @override
  State<WorkerEditProfileScreen> createState() =>
      _WorkerEditProfileScreenState();
}

class _WorkerEditProfileScreenState extends State<WorkerEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(
    text: 'Certified Electrician & HVAC Specialist',
  );
  final _rateController = TextEditingController(text: '650');
  final _bioController = TextEditingController(
    text: 'Experienced technician with 5+ years servicing residential, corporate, and industrial electrical boards, AC cooling systems, and backup generators across Dhaka.',
  );
  final AuthController _authController = AuthController();

  String _workingArea = 'All Dhaka City';
  String _verificationStatus = 'Pending'; // 'Pending' or 'Verified'
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
    _fetchWorkerProfile();
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

    try {
      final response = await Supabase.instance.client
          .from(DatabaseTables.workerProfiles)
          .select()
          .eq('user_id', user.uid)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _titleController.text = response['title'] ?? _titleController.text;
          _rateController.text = (response['expected_rate'] ?? 650).toString();
          _bioController.text = response['bio'] ?? _bioController.text;
          _workingArea = response['working_area'] ?? _workingArea;
          _verificationStatus =
              response['verification_status'] ?? _verificationStatus;
          _isAvailable = response['is_available'] ?? true;
        });
      }
    } catch (e) {
      debugPrint('[WorkerProfile Fetch Info]: $e');
    }
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _authController.user;
      final rate = double.tryParse(_rateController.text.trim()) ?? 650.0;

      if (user != null) {
        await Supabase.instance.client
            .from(DatabaseTables.workerProfiles)
            .upsert({
              'user_id': user.uid,
              'title': _titleController.text.trim(),
              'expected_rate': rate,
              'working_area': _workingArea,
              'bio': _bioController.text.trim(),
              'is_available': _isAvailable,
              'updated_at': DateTime.now().toIso8601String(),
            }, onConflict: 'user_id');
      }

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
    return Scaffold(
      backgroundColor: AppColors.primarySky,
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
                  const Text(
                    'Worker Profile',
                    style: TextStyle(
                      fontFamily: AppTypography.headingFont,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      AppAssets.emblem,
                      height: 22,
                      width: 22,
                      fit: BoxFit.contain,
                      errorBuilder: (_, error, stack) => const Icon(
                        Icons.engineering_rounded,
                        size: 18,
                        color: AppColors.primaryRoyal,
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
                decoration: const BoxDecoration(
                  color: AppColors.sheetSurface,
                  borderRadius: AppDimensions.roundedSheetTop,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Verification Status Banner (SRS Section 3.1.R)
                        WorkerVerificationBanner(
                          verificationStatus: _verificationStatus,
                        ),

                        const SizedBox(height: 24),

                        // Availability Toggle Switch
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sheetSurfaceSubtle,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Active Dispatch Status',
                                    style: TextStyle(
                                      fontFamily: AppTypography.headingFont,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    _isAvailable
                                        ? 'Ready for immediate job alerts'
                                        : 'Currently off-duty',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMedium,
                                    ),
                                  ),
                                ],
                              ),
                              Switch.adaptive(
                                value: _isAvailable,
                                activeTrackColor: AppColors.primarySky,
                                onChanged: (val) =>
                                    setState(() => _isAvailable = val),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Professional Title
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

                        // Expected Rate & Working Zone Row
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: AppTextField(
                                controller: _rateController,
                                label: 'Rate (৳/Hour)',
                                hint: '650',
                                keyboardType: TextInputType.number,
                                prefixIcon: const Icon(
                                  Icons.sell_outlined,
                                  color: AppColors.primarySky,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Working Zone',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMedium,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.sheetSurfaceSubtle,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppColors.borderLight,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _workingArea,
                                        isExpanded: true,
                                        items: _workingZones.map((z) {
                                          return DropdownMenuItem<String>(
                                            value: z,
                                            child: Text(
                                              z,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
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
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Bio
                        AppTextField(
                          controller: _bioController,
                          label: 'Professional Summary & Experience',
                          hint: 'Describe your certifications, experience, and past commercial/home repairs...',
                          maxLines: 3,
                        ),

                        const SizedBox(height: 24),

                        // Verification Documents Upload Cards (SRS Section 3.1.R)
                        WorkerDocumentUploadSection(
                          nidUploaded: _nidUploaded,
                          onToggleNid: () {
                            setState(() => _nidUploaded = !_nidUploaded);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'NID front & back documents uploaded.',
                                ),
                              ),
                            );
                          },
                          certUploaded: _certUploaded,
                          onToggleCert: () {
                            setState(() => _certUploaded = !_certUploaded);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Trade certification document uploaded.',
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 36),

                        // Save Button
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
