import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/utils/category_resolver.dart';
import '../../../../core/utils/supabase_guard.dart';
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

    final client = tryGetSupabaseClient();
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Offline mode: publishing opportunities requires an active backend connection.',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final budget = double.tryParse(_budgetController.text.trim()) ?? 1500.0;
    final catName = _categories[_selectedCategory] ?? 'General Trade';
    final normalizedUrgency = CategoryResolver.normalizeUrgency(_urgency);
    final normalizedType = CategoryResolver.normalizeRequirementType(
      _postType == 'Job' ? 'Simple' : 'Complex',
    );

    try {
      final resolvedCategoryUuid = await CategoryResolver.resolveCategoryUuid(
        client,
        _selectedCategory,
      );

      // 1. Persist to Supabase `requirements` table (SRS Section 3.1.D & 4.4)
      final inserted = await client
          .from(DatabaseTables.requirements)
          .insert({
            'submitted_by': user.uid,
            'category_id': ?resolvedCategoryUuid,
            'title': title,
            'description': desc,
            'requirement_type': normalizedType,
            'budget': budget,
            'location': _selectedLocation,
            'urgency': normalizedUrgency,
            'status': 'Open',
          })
          .select('requirement_id')
          .single();

      final reqId = inserted['requirement_id']?.toString() ?? '';

      final newItem = JobRequirementItem(
        id: reqId,
        title: title,
        category: catName,
        categoryId: resolvedCategoryUuid ?? _selectedCategory,
        description: desc,
        location: _selectedLocation,
        budgetMin: budget * 0.9,
        budgetMax: budget * 1.2,
        urgency: normalizedUrgency,
        timeAgo: 'Just now',
        clientName:
            user.displayName ?? user.email?.split('@').first ?? 'Member',
        postType: _postType,
        authorRole: 'Client',
        status: 'Open',
        likesCount: 0,
        commentsCount: 0,
        submittedBy: user.uid,
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
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: tokens.sheetBg,
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
                color: tokens.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: tokens.softBlueBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_task_rounded,
                      color: tokens.brandAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isBn
                          ? 'নতুন সুযোগ বা পোস্ট তৈরি করুন'
                          : 'Create Opportunity or Post',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
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
            Divider(height: 12, color: tokens.border),

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
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 50),
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitPost,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: tokens.brandAccent,
                              foregroundColor: tokens.onBrandAccent,
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppDimensions.roundedPill,
                              ),
                            ),
                            child: _isSubmitting
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: tokens.onBrandAccent,
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
