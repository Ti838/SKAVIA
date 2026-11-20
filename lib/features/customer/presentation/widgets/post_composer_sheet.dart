import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/utils/category_resolver.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../data/tables/database_tables.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/datasources/live_job_feed_datasource.dart';
import '../../data/models/requirement_model.dart';
import 'post_composer_fields.dart';
import 'post_type_selector.dart';

/// Modal composer for posting jobs, service requests, or professional updates.
class PostComposerSheet extends StatefulWidget {
  final String initialPostType;
  final Function(JobRequirementItem newItem)? onPostCreated;

  const PostComposerSheet({
    super.key,
    this.initialPostType = 'Job',
    this.onPostCreated,
  });

  static void show(
    BuildContext context, {
    String initialPostType = 'Job',
    Function(JobRequirementItem)? onPostCreated,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => PostComposerSheet(
        initialPostType: initialPostType,
        onPostCreated: onPostCreated,
      ),
    );
  }

  @override
  State<PostComposerSheet> createState() => _PostComposerSheetState();
}

class _PostComposerSheetState extends State<PostComposerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _budgetController = TextEditingController();
  final AuthController _authController = AuthController();

  late String _postType;
  String _selectedCategory = 'cat_electrical';
  String _selectedLocation = 'Dhanmondi, Dhaka';
  String _urgency = 'Standard';
  bool _isSubmitting = false;

  final Map<String, String> _categories = const {
    'cat_electrical': 'Electrical',
    'cat_ac_hvac': 'HVAC & AC',
    'cat_plumbing': 'Plumbing',
    'cat_civil_carpentry': 'Carpentry',
    'cat_it_creative': 'IT & Security',
    'cat_renovation': 'Interior & Paint',
  };

  @override
  void initState() {
    super.initState();
    _postType = widget.initialPostType;
  }

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
      UiFeedbackHelper.showError(
        context,
        'Please sign in to publish a post.',
      );
      return;
    }

    final client = tryGetSupabaseClient();
    if (client == null) {
      UiFeedbackHelper.showError(
        context,
        'An active backend connection is required to publish posts.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final rawTitle = _titleController.text.trim();
    final desc = _descController.text.trim();
    final budgetText = _budgetController.text.trim();
    final budget = budgetText.isEmpty
        ? 0.0
        : (double.tryParse(budgetText) ?? 0.0);
    final catName = _categories[_selectedCategory] ?? 'General';
    final normalizedUrgency = CategoryResolver.normalizeUrgency(_urgency);
    final normalizedType = CategoryResolver.normalizeRequirementType(
      _postType == 'Service Request' ? 'Complex' : 'Simple',
    );
    final persistedTitle = _postType == 'Professional Update'
        ? '${LiveJobFeedDataSource.updatePrefix}$rawTitle'
        : rawTitle;

    try {
      final resolvedCategoryUuid = await CategoryResolver.resolveCategoryUuid(
        client,
        _selectedCategory,
      );

      final inserted = await client
          .from(DatabaseTables.requirements)
          .insert({
            'submitted_by': user.uid,
            'category_id': ?resolvedCategoryUuid,
            'title': persistedTitle,
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
        title: rawTitle,
        category: catName,
        categoryId: resolvedCategoryUuid ?? _selectedCategory,
        description: desc,
        location: _selectedLocation,
        budgetMin: budget,
        budgetMax: budget,
        urgency: normalizedUrgency,
        timeAgo: 'Just now',
        clientName:
            user.displayName ?? user.email?.split('@').first ?? 'SKAVIA Member',
        postType: _postType,
        authorRole: 'Member',
        status: 'Open',
        likesCount: 0,
        commentsCount: 0,
        submittedBy: user.uid,
      );

      if (mounted) {
        widget.onPostCreated?.call(newItem);
        Navigator.pop(context);
        UiFeedbackHelper.showSuccess(
          context,
          AppLanguageService.isBengali
              ? 'পোস্ট সফলভাবে প্রকাশিত হয়েছে!'
              : 'Post published successfully.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        UiFeedbackHelper.showError(
          context,
          AppLanguageService.isBengali
              ? 'পোস্ট প্রকাশ করা যায়নি। আবার চেষ্টা করুন।'
              : 'Could not publish your post. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBn = AppLanguageService.isBengali;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.84,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    child: Icon(
                      Icons.edit_note_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isBn ? 'নতুন পোস্ট তৈরি করুন' : 'Create Post',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: isBn ? 'বন্ধ করুন' : 'Close',
                    icon: Icon(
                      Icons.close_rounded,
                      color: tokens.secondaryText,
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
                      PostTypeSelector(
                        selectedType: _postType,
                        onTypeChanged: (type) =>
                            setState(() => _postType = type),
                      ),
                      const SizedBox(height: 18),
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
                      AppButton(
                        text: isBn ? 'পোস্ট প্রকাশ করুন' : 'Publish Post',
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting ? null : _submitPost,
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
