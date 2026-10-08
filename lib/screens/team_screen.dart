import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/member_avatar.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  List<TeamMember> _members = [];
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final members = await StorageService.loadMembers();
    final tasks = await StorageService.loadTasks();
    if (!mounted) return;
    setState(() {
      _members = members;
      _tasks = tasks;
    });
  }

  // Calculated from the saved tasks, never typed in.
  int _openTasks(TeamMember member) => _tasks
      .where((task) =>
          task.assigneeId == member.id && task.status != TaskStatus.done)
      .length;

  Future<void> _addMember() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final roleController = TextEditingController();

    final added = await showDialog<TeamMember>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add member'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (value) {
                    final name = (value ?? '').trim();
                    if (name.length < 2) return 'Enter a name';
                    final exists = _members.any(
                      (m) => m.name.toLowerCase() == name.toLowerCase(),
                    );
                    if (exists) return 'This member already exists';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: roleController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Role'),
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Enter a role' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(
                dialogContext,
                TeamMember(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  role: roleController.text.trim(),
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (added == null) return;
    setState(() => _members.add(added));
    await StorageService.saveMembers(_members);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team'),
        actions: [
          IconButton(
            tooltip: 'Add member',
            icon: const Icon(PhosphorIconsRegular.userPlus),
            onPressed: _addMember,
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _members.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final member = _members[index];
          final open = _openTasks(member);
          return AppCard(
            child: Row(
              children: [
                MemberAvatar(members: _members, memberId: member.id),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name, style: AppText.cardTitle),
                      const SizedBox(height: 2),
                      Text(member.role, style: AppText.secondary),
                    ],
                  ),
                ),
                Text(
                  open == 1 ? '1 open task' : '$open open tasks',
                  style: AppText.secondary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
//....