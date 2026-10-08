import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/bottom_action_bar.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late String _title;
  late String _description;
  late String _category;
  String? _assigneeId;
  DateTime? _dueDate;
  late TaskPriority _priority;
  late TaskStatus _status;

  List<TeamMember> _members = [];
  bool _showErrorBanner = false;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = t?.title ?? '';
    _description = t?.description ?? '';
    _category = t?.category ?? taskCategories.first;
    _assigneeId = t?.assigneeId;
    _dueDate = t?.dueDate;
    _priority = t?.priority ?? TaskPriority.medium;
    _status = t?.status ?? TaskStatus.todo;

    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final members = await StorageService.loadMembers();
    if (mounted) setState(() => _members = members);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDate = (_dueDate != null && _dueDate!.isBefore(today)) ? _dueDate! : today;

    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? today,
      firstDate: firstDate,
      lastDate: today.add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _saveTask() async {
    final isValid = _formKey.currentState!.validate();
    setState(() => _showErrorBanner = !isValid);

    if (!isValid) return;

    _formKey.currentState!.save();

    final tasks = await StorageService.loadTasks();

    if (widget.task == null) {
      final newTask = Task(
        id: nextTaskId(tasks),
        title: _title,
        description: _description,
        category: _category,
        assigneeId: _assigneeId!,
        dueDate: _dueDate!,
        priority: _priority,
        status: _status,
      );
      tasks.add(newTask);
    } else {
      final index = tasks.indexWhere((t) => t.id == widget.task!.id);
      if (index != -1) {
        tasks[index].title = _title;
        tasks[index].description = _description;
        tasks[index].category = _category;
        tasks[index].assigneeId = _assigneeId!;
        tasks[index].dueDate = _dueDate!;
        tasks[index].priority = _priority;
        tasks[index].status = _status;
      }
    }

    await StorageService.saveTasks(tasks);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task saved')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Create Task'),
      ),
      bottomNavigationBar: BottomActionBar(
        children: [
          FilledButton(
            onPressed: _saveTask,
            child: const Text('SAVE TASK'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_showErrorBanner)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      const Icon(PhosphorIconsRegular.warningCircle, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please fix the errors below.',
                          style: AppText.cardTitle.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),

              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.length < 3 || text.length > 60) {
                    return 'Enter a title of at least 3 characters';
                  }
                  return null;
                },
                onSaved: (value) => _title = (value ?? '').trim(),
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: _description,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.length > 300) {
                    return 'Keep the description under 300 characters';
                  }
                  return null;
                },
                onSaved: (value) => _description = (value ?? '').trim(),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: taskCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
                onSaved: (val) => _category = val!,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _assigneeId,
                decoration: const InputDecoration(labelText: 'Assign to'),
                items: _members
                    .map((m) => DropdownMenuItem(value: m.id, child: Text(m.name)))
                    .toList(),
                validator: (value) => value == null ? 'Choose a team member' : null,
                onChanged: (val) {
                  if (val != null) setState(() => _assigneeId = val);
                },
                onSaved: (val) => _assigneeId = val,
              ),
              const SizedBox(height: 16),

              FormField<DateTime>(
                initialValue: _dueDate,
                validator: (val) {
                  if (_dueDate == null) return 'Choose a due date';
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  if (_dueDate!.isBefore(today)) return 'The due date cannot be in the past';
                  return null;
                },
                builder: (state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          _pickDate().then((_) {
                            state.didChange(_dueDate);
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Due date',
                            errorText: state.errorText,
                          ),
                          child: Text(
                            _dueDate == null ? 'Select date' : formatDate(_dueDate!),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              const Text('Priority', style: AppText.cardTitle),
              const SizedBox(height: 8),
              SegmentedButton<TaskPriority>(
                segments: const [
                  ButtonSegment(value: TaskPriority.low, label: Text('Low')),
                  ButtonSegment(value: TaskPriority.medium, label: Text('Medium')),
                  ButtonSegment(value: TaskPriority.high, label: Text('High')),
                ],
                selected: {_priority},
                onSelectionChanged: (set) {
                  setState(() => _priority = set.first);
                },
              ),
              const SizedBox(height: 24),

              DropdownButtonFormField<TaskStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: TaskStatus.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(statusLabel(s))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
                onSaved: (val) => _status = val!,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
