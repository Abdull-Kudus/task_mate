import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/member_avatar.dart';
import '../widgets/section_header.dart';
import '../widgets/sla_badge.dart';
import '../widgets/task_card.dart';
import 'statistics_screen.dart';
import 'task_details_screen.dart';
import 'task_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onSeeAllTasks;
  const DashboardScreen({super.key, this.onSeeAllTasks});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Task> _tasks = [];
  List<TeamMember> _members = [];
  String? _userId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tasks = await StorageService.loadTasks();
    final members = await StorageService.loadMembers();
    final userId = await StorageService.getCurrentUserId();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _members = members;
      _userId = userId;
      _loading = false;
    });
  }

  int _count(SlaStatus status) =>
      _tasks.where((task) => SlaService.statusFor(task) == status).length;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _open(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final total = _tasks.length;
    final completed = _count(SlaStatus.completed);
    final percent = total == 0 ? 0 : (completed * 100 / total).round();
    final firstName = memberName(_members, _userId ?? '').split(' ').first;

    final attention = _tasks.where((task) {
      final sla = SlaService.statusFor(task);
      return sla == SlaStatus.overdue || sla == SlaStatus.atRisk;
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: MemberAvatar(
              members: _members,
              memberId: _userId,
              radius: 16,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create task',
        onPressed: () => _open(const TaskFormScreen()),
        child: const Icon(PhosphorIconsRegular.plus),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              children: [
                Text('$_greeting, $firstName', style: AppText.title),
                const SizedBox(height: 4),
                Text(
                  formatLongDate(DateTime.now()),
                  style: AppText.secondary,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    _StatCard(
                      label: 'TOTAL TASKS',
                      count: total,
                      icon: PhosphorIconsRegular.listChecks,
                      color: AppColors.onPrimary,
                      background: AppColors.primary,
                      borderColor: AppColors.primary,
                    ),
                    for (final status in const [
                      SlaStatus.onTrack,
                      SlaStatus.atRisk,
                      SlaStatus.overdue,
                    ])
                      _StatCard(
                        label: slaStyleFor(status).label.toUpperCase(),
                        count: _count(status),
                        icon: slaStyleFor(status).icon,
                        color: slaStyleFor(status).color,
                        background: slaStyleFor(status).background,
                        borderColor: slaStyleFor(status).color.withAlpha(77),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$completed of $total tasks completed',
                              style: AppText.cardTitle,
                            ),
                          ),
                          Text('$percent%', style: AppText.cardTitle),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : completed / total,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () => _open(StatisticsScreen(tasks: _tasks)),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'VIEW STATS',
                              style: AppText.caps
                                  .copyWith(color: AppColors.primaryDark),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Needs attention',
                  actionLabel: 'SEE ALL',
                  onAction: widget.onSeeAllTasks,
                ),
                const SizedBox(height: 8),
                if (attention.isEmpty)
                  const Text(
                    'Nothing is at risk or overdue.',
                    style: AppText.secondary,
                  ),
                for (final task in attention)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TaskCard(
                      task: task,
                      members: _members,
                      onTap: () => _open(TaskDetailsScreen(task: task)),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final Color background;
  final Color borderColor;

  const _StatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.background,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      color: background,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$count', style: AppText.number.copyWith(color: color)),
              Text(label, style: AppText.caps.copyWith(color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
