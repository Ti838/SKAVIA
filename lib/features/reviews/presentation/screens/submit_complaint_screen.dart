import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../core/utils/uuid_util.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/datasources/complaint_remote_datasource.dart';

class SubmitComplaintScreen extends StatefulWidget {
  final String? serviceRequestId;
  final String? projectId;

  const SubmitComplaintScreen({
    super.key,
    this.serviceRequestId,
    this.projectId,
  });

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final ComplaintRemoteDataSource _dataSource = ComplaintRemoteDataSource();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = 'Work Quality';
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _complaints = [];

  static const List<String> _categories = [
    'Work Quality',
    'Delay',
    'Behavior',
    'Billing',
  ];

  @override
  void initState() {
    super.initState();
    _referenceController.text =
        widget.serviceRequestId ?? widget.projectId ?? '';
    _loadComplaints();
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadComplaints() async {
    final userId = _dataSource.resolveUserId();
    if (_complaints.isEmpty) {
      final cached = _dataSource.getCachedComplaints(userId);
      if (cached.isNotEmpty) {
        setState(() => _complaints = cached);
      }
    }

    final list = await _dataSource.fetchComplaints(userId);
    if (mounted) {
      setState(() => _complaints = list);
    }
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    final userId = _dataSource.resolveUserId();
    final refInput = _referenceController.text.trim();
    final isUuid = UuidUtil.isValidUuid(refInput);
    final fullDesc = (!isUuid && refInput.isNotEmpty)
        ? '[Ref: $refInput] ${_descriptionController.text.trim()}'
        : _descriptionController.text.trim();

    final payload = <String, dynamic>{
      'complaint_id': UuidUtil.generateUuidV4(),
      'filed_by': userId,
      if (widget.serviceRequestId != null &&
          UuidUtil.isValidUuid(widget.serviceRequestId!))
        'service_request_id': widget.serviceRequestId
      else if (isUuid && widget.projectId == null)
        'service_request_id': refInput,
      if (widget.projectId != null && UuidUtil.isValidUuid(widget.projectId!))
        'project_id': widget.projectId,
      'category': _selectedCategory,
      'description': fullDesc,
      'status': 'Open',
      'created_at': DateTime.now().toIso8601String(),
    };

    final submittedOnline = await _dataSource.submitComplaint(
      userId: userId,
      payload: payload,
    );

    if (!mounted) return;
    setState(() {
      _complaints = [payload, ..._complaints];
      _descriptionController.clear();
      _isSubmitting = false;
    });

    UiFeedbackHelper.showSuccess(
      context,
      submittedOnline
          ? 'Complaint submitted for admin mediation.'
          : 'Complaint saved offline and queued for sync.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;

    return Scaffold(
      appBar: const AppAppBar(title: 'Submit a Complaint'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          children: [
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Issue Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _categories.map((cat) {
                        final selected = _selectedCategory == cat;
                        return InkWell(
                          onTap: () => setState(() => _selectedCategory = cat),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? tokens.brandAccent.withValues(alpha: 0.14)
                                  : colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? tokens.brandAccent
                                    : tokens.subtleBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (selected) ...[
                                  Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: tokens.brandAccent,
                                  ),
                                  const SizedBox(width: 5),
                                ],
                                Flexible(
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: selected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: selected
                                          ? tokens.brandAccent
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _referenceController,
                      label: 'Booking / Project Reference (Optional)',
                      hint: 'Service request ID or description',
                      prefixIcon: const Icon(Icons.tag_rounded),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _descriptionController,
                      label: 'Describe What Happened',
                      hint: 'Provide timeline, specialist details & expected resolution',
                      maxLines: 4,
                      validator: (val) =>
                          val == null || val.trim().length < 15
                          ? 'Please describe the issue in at least 15 characters'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Submit Formal Complaint',
                      isLoading: _isSubmitting,
                      onPressed: _submitComplaint,
                    ),
                  ],
                ),
              ),
            ),

            if (_complaints.isNotEmpty) ...[
              const SizedBox(height: 22),
              Text(
                'Your Recent Complaints',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              ..._complaints.map((c) {
                final status = c['status']?.toString() ?? 'Open';
                final isResolved =
                    status == 'Resolved' || status == 'Closed';
                final badgeColor = isResolved
                    ? AppColors.success
                    : AppColors.warning;
                final createdAt = DateTime.tryParse(
                  c['created_at']?.toString() ?? '',
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                c['category']?.toString() ?? 'General',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: badgeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c['description']?.toString() ?? '',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        if (createdAt != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            Formatters.formatDateTime(createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: tokens.mutedText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

