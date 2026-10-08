import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/member_avatar.dart';
import 'sign_in_screen.dart';
import 'statistics_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<TeamMember> _members = [];
  List<Task> _tasks = [];
  String? _userId;
  String _email = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = await StorageService.getCurrentUserId();
    final email = await StorageService.getEmail();
    final members = await StorageService.loadMembers();
    final tasks = await StorageService.loadTasks();
    if (!mounted) return;
    setState(() {
      _userId = userId;
      _email = email;
      _members = members;
      _tasks = tasks;
    });
  }

  TeamMember? get _user {
    for (final member in _members) {
      if (member.id == _userId) return member;
    }
    return null;
  }

  List<Task> get _myTasks =>
      _tasks.where((task) => task.assigneeId == _userId).toList();

  int _count(SlaStatus status) =>
      _myTasks.where((t) => SlaService.statusFor(t) == status).length;

  Future<void> _editProfile() async {
    final user = _user;
    if (user == null) return;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.name);
    final roleController = TextEditingController(text: user.role);

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit profile'),
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
                  validator: (value) =>
                      (value ?? '').trim().length < 2 ? 'Enter a name' : null,
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
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true) return;
    setState(() {
      user.name = nameController.text.trim();
      user.role = roleController.text.trim();
    });
    await StorageService.saveMembers(_members);
  }

  Future<void> _signOut() async {
    // rootNavigator replaces the whole app, including the bottom bar.
    final navigator = Navigator.of(context, rootNavigator: true);
    await StorageService.signOut();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(
            child: MemberAvatar(
              members: _members,
              memberId: _userId,
              radius: 40,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user?.name ?? 'Guest',
            textAlign: TextAlign.center,
            style: AppText.title,
          ),
          const SizedBox(height: 2),
          Text(
            user?.role ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(_email, textAlign: TextAlign.center, style: AppText.secondary),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _Stat(label: 'ASSIGNED', value: _myTasks.length),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Stat(
                  label: 'COMPLETED',
                  value: _count(SlaStatus.completed),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Stat(
                  label: 'OVERDUE',
                  value: _count(SlaStatus.overdue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(PhosphorIconsRegular.chartBar),
                  title: const Text('Task statistics'),
                  trailing: const Icon(PhosphorIconsRegular.caretRight),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StatisticsScreen(tasks: _tasks),
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(PhosphorIconsRegular.pencilSimple),
                  title: const Text('Edit profile'),
                  trailing: const Icon(PhosphorIconsRegular.caretRight),
                  onTap: _editProfile,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(PhosphorIconsRegular.info),
                  title: const Text('About'),
                  trailing: const Icon(PhosphorIconsRegular.caretRight),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'TaskMate',
                    applicationVersion: '1.0.0',
                    children: const [
                      Text('A project and SLA task tracker for small teams.'),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    PhosphorIconsRegular.signOut,
                    color: AppColors.error,
                  ),
                  title: const Text(
                    'Sign out',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: _signOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text('$value', style: AppText.number),
          const SizedBox(height: 2),
          Text(label, style: AppText.caps),
        ],
      ),
    );
  }
}
//...
