import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/sla_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/sla_badge.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Task> tasks;

  const StatisticsScreen({super.key, required this.tasks});

  int _count(SlaStatus status) =>
      tasks.where((task) => SlaService.statusFor(task) == status).length;

  @override
  Widget build(BuildContext context) {
    var highest = 1;
    for (final status in SlaStatus.values) {
      if (_count(status) > highest) highest = _count(status);
    }

    final upcoming = tasks
        .where((task) => task.status != TaskStatus.done)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Scaffold(
      appBar: AppBar(title: const Text('Task Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TASKS BY SLA STATUS', style: AppText.caps),
                const SizedBox(height: 16),
                Row(
                  children: [
                    for (final status in SlaStatus.values)
                      Expanded(
                        child: _Bar(
                          count: _count(status),
                          highest: highest,
                          style: slaStyleFor(status),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Upcoming deadlines', style: AppText.cardTitle),
          const SizedBox(height: 12),
          if (upcoming.isEmpty)
            const Text('No open tasks.', style: AppText.secondary),
          for (final task in upcoming.take(5))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatDate(task.dueDate),
                            style: AppText.secondary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SlaBadge(status: SlaService.statusFor(task)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final int count;
  final int highest;
  final SlaStyle style;

  const _Bar({
    required this.count,
    required this.highest,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count', style: AppText.cardTitle),
        const SizedBox(height: 8),
        Container(
          height: 140,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: style.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FractionallySizedBox(
            widthFactor: 1,
            heightFactor: count / highest,
            child: ColoredBox(color: style.color),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          style.label,
          textAlign: TextAlign.center,
          style: AppText.secondary,
        ),
      ],
    );
  }
}
