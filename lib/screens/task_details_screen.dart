import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/sla_badge.dart';
import 'task_form_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final _notesController = TextEditingController();
  late Task _task;
  List<TeamMember> _members = [];

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _notesController.text = _task.notes;
    _load();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Reads the newest copy of this task, for example after an edit.
  Future<void> _load() async {
    final members = await StorageService.loadMembers();
    final tasks = await StorageService.loadTasks();
    final matches = tasks.where((t) => t.id == widget.task.id);
    if (!mounted) return;
    setState(() {
      _members = members;
      if (matches.isNotEmpty) {
        _task = matches.first;
        _notesController.text = _task.notes;
      }
    });
  }

  // Writes this task back into the saved list.
  Future<void> _persist() async {
    final tasks = await StorageService.loadTasks();
    final index = tasks.indexWhere((t) => t.id == _task.id);
    if (index != -1) tasks[index] = _task;
    await StorageService.saveTasks(tasks);
  }

  Future<void> _changeStatus(TaskStatus status) async {
    setState(() => _task.status = status); // badge updates at once
    await _persist();
  }

  Future<void> _saveNotes() async {
    final messenger = ScaffoldMessenger.of(context);
    FocusScope.of(context).unfocus();
    _task.notes = _notesController.text.trim();
    await _persist();
    messenger.showSnackBar(const SnackBar(content: Text('Notes saved')));
  }

  Future<void> _edit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: _task)),
    );
    _load();
  }

  Future<void> _delete() async {
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this task?'),
        content: Text('${_task.title} will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final tasks = await StorageService.loadTasks();
    tasks.removeWhere((t) => t.id == _task.id);
    await StorageService.saveTasks(tasks);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final sla = SlaService.statusFor(_task);
    final style = slaStyleFor(sla);

    return Scaffold(
      appBar: AppBar(title: const Text('Task Details')),
      // Pinned to the bottom, so it stays visible while the body scrolls.
      bottomNavigationBar: BottomActionBar(
        children: [
          FilledButton(onPressed: _edit, child: const Text('Edit Task')),
          TextButton(
            onPressed: _delete,
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete task'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${_task.code} · ${_task.category}',
            style: AppText.secondary,
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(_task.title, style: AppText.title)),
              const SizedBox(width: 8),
              SlaBadge(status: sla),
            ],
          ),
          if (_task.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _task.description,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              children: [
                _InfoRow(
                  icon: PhosphorIconsRegular.user,
                  label: 'Assigned to',
                  value: memberName(_members, _task.assigneeId),
                ),
                const Divider(height: 24),
                _InfoRow(
                  icon: PhosphorIconsRegular.calendarBlank,
                  label: 'Due date',
                  value: formatDate(_task.dueDate),
                ),
                const Divider(height: 24),
                _InfoRow(
                  icon: PhosphorIconsRegular.flag,
                  label: 'Priority',
                  value: priorityLabel(_task.priority),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // The key makes the field rebuild when the status changes
          // somewhere else, for example after an edit.
          DropdownButtonFormField<TaskStatus>(
            key: ValueKey(_task.status),
            value: _task.status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: [
              for (final status in TaskStatus.values)
                DropdownMenuItem(
                  value: status,
                  child: Text(statusLabel(status)),
                ),
            ],
            onChanged: (status) {
              if (status != null) _changeStatus(status);
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: style.color.withAlpha(77)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(style.icon, color: style.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SLA STATUS',
                        style: AppText.caps.copyWith(color: style.color),
                      ),
                      const SizedBox(height: 4),
                      Text(SlaService.explain(_task)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: _saveNotes,
              child: const Text('Save notes'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
