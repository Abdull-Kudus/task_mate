import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/sla_badge.dart';
import '../widgets/task_card.dart';
import 'task_details_screen.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // null means the All chip.
  static const _filters = <SlaStatus?>[
    null,
    SlaStatus.onTrack,
    SlaStatus.atRisk,
    SlaStatus.overdue,
    SlaStatus.completed,
  ];

  final _searchController = TextEditingController();
  List<Task> _tasks = [];
  List<TeamMember> _members = [];
  String _query = '';
  SlaStatus? _filter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final tasks = await StorageService.loadTasks();
    final members = await StorageService.loadMembers();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _members = members;
    });
  }

  // The tasks that match both the search text and the chosen chip.
  List<Task> get _visible {
    final query = _query.trim().toLowerCase();
    return _tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(query) ||
          task.code.toLowerCase().contains(query);
      final matchesFilter =
          _filter == null || SlaService.statusFor(task) == _filter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
      _filter = null;
    });
  }

  Future<void> _open(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    _load();
  }

  Future<bool> _confirmDelete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this task?'),
        content: Text('${task.title} will be removed permanently.'),
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
    return confirmed ?? false;
  }

  Future<void> _delete(Task task) async {
    setState(() => _tasks.removeWhere((t) => t.id == task.id));
    await StorageService.saveTasks(_tasks);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create task',
        onPressed: () => _open(const TaskFormScreen()),
        child: const Icon(PhosphorIconsRegular.plus),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search tasks',
                prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final filter in _filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        filter == null ? 'All' : slaStyleFor(filter).label,
                      ),
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                  ),
              ],
            ),
          ),
          // Expanded gives the list the rest of the screen height.
          Expanded(
            child: visible.isEmpty
                ? _EmptyState(onClear: _clearSearch)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final task = visible[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: ValueKey(task.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(
                              PhosphorIconsRegular.trash,
                              color: AppColors.error,
                            ),
                          ),
                          confirmDismiss: (_) => _confirmDelete(task),
                          onDismissed: (_) => _delete(task),
                          child: TaskCard(
                            task: task,
                            members: _members,
                            onTap: () => _open(TaskDetailsScreen(task: task)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onClear;

  const _EmptyState({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.surfaceMuted,
            child: Icon(
              PhosphorIconsRegular.magnifyingGlass,
              size: 32,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const Text('No tasks match your search', style: AppText.cardTitle),
          const SizedBox(height: 4),
          const Text(
            'Try a different word or filter.',
            style: AppText.secondary,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onClear,
            child: const Text('Clear search'),
          ),
        ],
      ),
    );
  }
}
