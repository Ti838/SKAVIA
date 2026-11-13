import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_app_bar.dart';
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

  final List<Map<String, String>> _availableSpecialists = const [
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
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: tokens.sheetBg,
      appBar: const AppAppBar(title: 'Assign Deliverable / Task'),
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
                style: TextStyle(color: colorScheme.onSurface),
                validator: (val) =>
                    Validators.requiredField(val, 'Task title is required'),
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'e.g. Sub-panel Conduit & Circuit Testing',
                  filled: true,
                  fillColor: tokens.inputBg,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Detailed Scope & Acceptance Criteria',
                  hintText:
                      'Mention required equipment, safety protocols, and SLA',
                  filled: true,
                  fillColor: tokens.inputBg,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Milestone Payout (৳ BDT)',
                  hintText: 'e.g. 8500',
                  filled: true,
                  fillColor: tokens.inputBg,
                  border: const OutlineInputBorder(),
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
                runSpacing: 8,
                children: ['Low', 'Medium', 'High', 'Urgent'].map((p) {
                  final isSelected = _priority == p;
                  return ChoiceChip(
                    label: Text(p),
                    selected: isSelected,
                    selectedColor: tokens.softBlueBg,
                    backgroundColor: tokens.subtleCardBg,
                    side: BorderSide(
                      color: isSelected ? tokens.brandAccent : tokens.border,
                    ),
                    labelStyle: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? tokens.brandAccent
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
                isExpanded: true,
                dropdownColor: tokens.cardBg,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: tokens.inputBg,
                  border: const OutlineInputBorder(),
                ),
                items: _availableSpecialists.map((s) {
                  return DropdownMenuItem(
                    value: s['id'],
                    child: Text(
                      s['name']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
