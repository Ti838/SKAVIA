import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/models/task_item_model.dart';

/// Screen allowing project managers or team leaders to assign new deliverables.
class AssignTaskScreen extends StatefulWidget {
  final String projectId;

  const AssignTaskScreen({super.key, required this.projectId});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _budgetController = TextEditingController();

  String _priority = 'Medium';
  String _assignedWorkerName = 'Rahul Ahmed (Electrician)';
  String _assignedWorkerId = 'worker_01';

  final List<Map<String, String>> _availableSpecialists = [
    {'id': 'worker_01', 'name': 'Rahul Ahmed (Electrician)'},
    {'id': 'worker_02', 'name': 'Kamal Hossain (Plumbing Lead)'},
    {'id': 'worker_03', 'name': 'Engr. Tariqul Islam (HVAC Consultant)'},
    {'id': 'worker_04', 'name': 'Sultana Begum (Quality Auditor)'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState?.validate() ?? false) {
      final task = TaskItemModel(
        taskId: 'task_${DateTime.now().millisecondsSinceEpoch}',
        projectId: widget.projectId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priority: _priority,
        status: 'To Do',
        assignedWorkerId: _assignedWorkerId,
        assignedWorkerName: _assignedWorkerName,
        budgetWeight: double.tryParse(_budgetController.text.trim()) ?? 5000.0,
        deadline: DateTime.now().add(const Duration(days: 7)),
      );

      UiFeedbackHelper.showSuccess(
        context,
        'Task assigned to $_assignedWorkerName',
      );
      Navigator.of(context).pop(task);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Assign Deliverable / Task',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Task Details',
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                validator: (val) =>
                    Validators.requiredField(val, 'Task title is required'),
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'e.g. Sub-panel Conduit & Circuit Testing',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Detailed Scope & Acceptance Criteria',
                  hintText:
                      'Mention required equipment, safety protocols, and SLA',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Milestone Payout (৳ BDT)',
                  hintText: 'e.g. 8500',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Priority Selector
              Text(
                'Priority Level',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Low', 'Medium', 'High', 'Urgent'].map((p) {
                  final isSelected = _priority == p;
                  return ChoiceChip(
                    label: Text(p),
                    selected: isSelected,
                    selectedColor: AppColors.primarySky.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primaryRoyal
                          : colorScheme.onSurface,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _priority = p);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Specialist Assignee
              Text(
                'Assign to Team Specialist',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _assignedWorkerId,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _availableSpecialists.map((s) {
                  return DropdownMenuItem(
                    value: s['id'],
                    child: Text(s['name']!),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _assignedWorkerId = val;
                      _assignedWorkerName = _availableSpecialists.firstWhere(
                        (s) => s['id'] == val,
                      )['name']!;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),

              AppButton(text: 'Confirm & Dispatch Task', onPressed: _saveTask),
            ],
          ),
        ),
      ),
    );
  }
}
