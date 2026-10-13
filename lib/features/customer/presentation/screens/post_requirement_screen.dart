import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../data/tables/database_tables.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../core/services/skavia_ai_service.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/models/category_model.dart';
import '../widgets/post_requirement_location_budget_picker.dart';
import '../widgets/post_requirement_stepper.dart';
import '../widgets/post_requirement_success_dialog.dart';
import '../widgets/requirement_type_selector.dart';

class PostRequirementScreen extends StatefulWidget {
  final String? preselectedCategory;

  const PostRequirementScreen({super.key, this.preselectedCategory});

  @override
  State<PostRequirementScreen> createState() => _PostRequirementScreenState();
}

class _PostRequirementScreenState extends State<PostRequirementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController(text: '1500');
  final AuthController _authController = AuthController();

  String _requirementType = 'Individual'; // 'Individual' vs 'Team Project'
  String _selectedCategory = 'cat_electrical';
  String _selectedLocation = 'Gulshan, Dhaka';
  DateTime? _selectedDeadline;
  String _selectedBudgetRange = '৳2,000 - ৳5,000';
  final List<String> _budgetRangeOptions = [
    '৳500 - ৳2,000',
    '৳2,000 - ৳5,000',
    '৳5,000 - ৳15,000',
    '৳15,000 - ৳50,000',
    '৳50,000+',
  ];
  bool _isSubmitting = false;
  bool _isDiagnosing = false;

  final List<String> _dhakaZones = [
    'Gulshan, Dhaka',
    'Banani, Dhaka',
    'Dhanmondi, Dhaka',
    'Mirpur, Dhaka',
    'Uttara, Dhaka',
    'Mohakhali, Dhaka',
    'Motijheel, Dhaka',
    'Badda / Rampura, Dhaka',
    'Bashundhara R/A, Dhaka',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.preselectedCategory != null) {
      _selectedCategory = widget.preselectedCategory!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _authController.dispose();
    super.dispose();
  }

  Future<void> _runAiDiagnosis() async {
    if (_isDiagnosing) return; // Prevent duplicate submissions
    final text = _descriptionController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a brief description first, then tap Auto-Diagnose!',
          ),
        ),
      );
      return;
    }

    setState(() => _isDiagnosing = true);
    try {
      final diag = await SkaviaAiService().diagnoseRequirement(text);
      if (diag != null && mounted) {
        final catId = diag['category_id'] as String?;
        final title = diag['suggested_title'] as String?;
        final budget = diag['budget_estimate'];
        final summary =
            diag['technical_summary'] as String? ?? 'Analysis complete';

        setState(() {
          if (catId != null) {
            _selectedCategory = catId;
          }
          if (title != null && title.isNotEmpty) {
            _titleController.text = title;
          }
          if (budget != null) {
            _budgetController.text = (budget is num)
                ? budget.toStringAsFixed(0)
                : budget.toString();
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SKAVIA AI: $summary'),
            backgroundColor: AppColors.primaryRoyal,
            duration: const Duration(seconds: 4),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'AI diagnosis returned empty result. Please enter details manually.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI Diagnosis Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDiagnosing = false);
    }
  }

  Future<void> _handleSubmitRequirement() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    final user = _authController.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to post a service requirement.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final budget = double.tryParse(_budgetController.text.trim()) ?? 1500.0;

      // Submit to Supabase `requirements` table (SRS Section 3.1.D & 4.4)
      await Supabase.instance.client.from(DatabaseTables.requirements).insert({
        'submitted_by': user.uid,
        'category_id': _selectedCategory,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'requirement_type': _requirementType,
        'budget': budget,
        'location': _selectedLocation,
        'status': 'Open',
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      // Show Success Dialog only on genuine database success
      await PostRequirementSuccessDialog.show(
        context,
        title: _titleController.text.trim(),
        budget: budget,
        selectedLocation: _selectedLocation,
        requirementType: _requirementType,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post requirement: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar matching Screen 6 (Request a Service)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textDark,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Request a Service',
                    style: TextStyle(
                      fontFamily: AppTypography.headingFont,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Horizontal Stepper Indicator matching Screen 6
            const PostRequirementStepper(activeStep: 1),

            const Divider(height: 1, color: AppColors.borderLight),

            // Form Container
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header matching Screen 6
                      const Text(
                        'Service Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Requirement Type Switcher (SRS Section 3.1.D)
                      RequirementTypeSelector(
                        selectedType: _requirementType,
                        onTypeChanged: (type) =>
                            setState(() => _requirementType = type),
                      ),

                      const SizedBox(height: 24),

                      // Trade Category Picker
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontFamily: AppTypography.headingFont,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.sheetSurfaceSubtle,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.arrow_drop_down_rounded,
                              color: AppColors.primarySky,
                            ),
                            items: CategoryModel.defaultCategories.map((cat) {
                              return DropdownMenuItem<String>(
                                value: cat.categoryId,
                                child: Text(
                                  cat.name,
                                  style: const TextStyle(
                                    fontFamily: AppTypography.bodyFont,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedCategory = val);
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Service Title matching Screen 6
                      AppTextField(
                        controller: _titleController,
                        label: 'Service Title',
                        hint: 'e.g. Mobile App Development',
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? 'Please enter a title'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // Description matching Screen 6
                      AppTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Describe your requirements in detail...',
                        maxLines: 4,
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? 'Please provide details'
                            : null,
                      ),

                      const SizedBox(height: 8),

                      // SKAVIA AI Auto-Diagnose Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: _isDiagnosing ? null : _runAiDiagnosis,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryRoyal.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primarySky.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isDiagnosing)
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.auto_awesome,
                                    color: AppColors.primaryRoyal,
                                    size: 14,
                                  ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Auto-Diagnose with SKAVIA AI',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryRoyal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Deadline matching Screen 6
                      const Text(
                        'Deadline',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                _selectedDeadline ??
                                DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setState(() => _selectedDeadline = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sheetSurfaceSubtle,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: AppColors.textMedium,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDeadline != null
                                    ? '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}'
                                    : 'Select deadline',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _selectedDeadline != null
                                      ? AppColors.textDark
                                      : AppColors.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Budget & Location Selector Section
                      PostRequirementLocationBudgetPicker(
                        selectedBudgetRange: _selectedBudgetRange,
                        budgetRangeOptions: _budgetRangeOptions,
                        onBudgetRangeChanged: (val) {
                          setState(() {
                            _selectedBudgetRange = val;
                            if (val.contains('500')) {
                              _budgetController.text = '1500';
                            } else if (val.contains('2,000')) {
                              _budgetController.text = '3500';
                            } else if (val.contains('5,000')) {
                              _budgetController.text = '8000';
                            } else if (val.contains('15,000')) {
                              _budgetController.text = '25000';
                            } else {
                              _budgetController.text = '60000';
                            }
                          });
                        },
                        selectedLocation: _selectedLocation,
                        dhakaZones: _dhakaZones,
                        onLocationChanged: (val) {
                          setState(() => _selectedLocation = val);
                        },
                      ),

                      const SizedBox(height: 32),

                      // Submit Button matching Screen 6 (Next)
                      AppButton(
                        text: _isSubmitting ? 'Posting Requirement...' : 'Next',
                        isLoading: _isSubmitting,
                        onPressed: _handleSubmitRequirement,
                      ),
                    ],
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
