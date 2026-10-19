import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/utils/uuid_util.dart';
import '../../../../data/tables/database_tables.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/models/requirement_model.dart';
import 'post_composer_fields.dart';
import 'post_type_selector.dart';

/// Modal composer for posting opportunities, service requests, or professional updates
class PostComposerSheet extends StatefulWidget {
  final Function(JobRequirementItem newItem)? onPostCreated;

  const PostComposerSheet({super.key, this.onPostCreated});

  static void show(
    BuildContext context, {
    Function(JobRequirementItem)? onPostCreated,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PostComposerSheet(onPostCreated: onPostCreated),
    );
  }

  @override
  State<PostComposerSheet> createState() => _PostComposerSheetState();
}

class _PostComposerSheetState extends State<PostComposerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _budgetController = TextEditingController(text: '1500');
  final AuthController _authController = AuthController();

  String _postType = 'Job'; // 'Job', 'Service Request', 'Professional Update'
  String _selectedCategory = 'cat_electrical';
  String _selectedLocation = 'Dhanmondi, Dhaka';
  String _urgency = 'Standard';
  bool _isSubmitting = false;

  final Map<String, String> _categories = {
    'cat_electrical': 'Electrical',
    'cat_ac_hvac': 'HVAC & AC',
    'cat_plumbing': 'Plumbing',
    'cat_civil_carpentry': 'Carpentry',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _budgetController.dispose();
    _authController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    final user = _authController.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to publish an opportunity.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final budget = double.tryParse(_budgetController.text.trim()) ?? 1500.0;
    final catName = _categories[_selectedCategory] ?? 'General Trade';

    final reqId = UuidUtil.generateV4();

    try {
      // 1. Persist to Supabase `requirements` table (SRS Section 3.1.D & 4.4)
      await Supabase.instance.client.from(DatabaseTables.requirements).insert({
        'requirement_id': reqId,
        'submitted_by': user.uid,
        'category_id': _selectedCategory,
        'title': title,
        'description': desc,
        'requirement_type': _postType == 'Job' ? 'Simple' : 'Complex',
        'budget': budget,
        'location': _selectedLocation,
        'urgency': _urgency,
        'status': 'Open',
        'created_at': DateTime.now().toIso8601String(),
      });

      final newItem = JobRequirementItem(
        id: reqId,
        title: title,
        category: catName,
        categoryId: _selectedCategory,
        description: desc,
        location: _selectedLocation,
        budgetMin: budget * 0.9,
        budgetMax: budget * 1.2,
        urgency: _urgency,
        timeAgo: 'Just now',
        clientName:
            user.displayName ?? user.email?.split('@').first ?? 'Member',
        postType: _postType,
        authorRole: 'Client',
        status: 'Open',
        likesCount: 0,
        commentsCount: 0,
      );

      if (mounted) {
        widget.onPostCreated?.call(newItem);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opportunity published successfully!'),
            backgroundColor: AppColors.primaryRoyal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppDimensions.roundedSheet,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primarySky.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_task_rounded,
                          color: AppColors.primaryRoyal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isBn
                            ? 'নতুন সুযোগ বা পোস্ট তৈরি করুন'
                            : 'Create Opportunity or Post',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 12, color: colorScheme.outlineVariant),

            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bottomInset),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post Type Pill Selector
                      PostTypeSelector(
                        selectedType: _postType,
                        onTypeChanged: (type) =>
                            setState(() => _postType = type),
                      ),
                      const SizedBox(height: 18),

                      // Modular Post Composer Input Fields
                      PostComposerFields(
                        titleController: _titleController,
                        descController: _descController,
                        budgetController: _budgetController,
                        selectedCategory: _selectedCategory,
                        onCategoryChanged: (cat) =>
                            setState(() => _selectedCategory = cat),
                        selectedLocation: _selectedLocation,
                        onLocationChanged: (loc) =>
                            setState(() => _selectedLocation = loc),
                        urgency: _urgency,
                        onUrgencyChanged: (urg) =>
                            setState(() => _urgency = urg),
                        categories: _categories,
                      ),
                      const SizedBox(height: 24),

                      // Publish Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitPost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRoyal,
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppDimensions.roundedPill,
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isBn
                                      ? 'পোস্ট প্রকাশ করুন'
                                      : 'Publish Opportunity',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
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
