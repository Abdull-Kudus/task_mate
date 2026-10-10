import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../models/task.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'app_card.dart';
import 'member_avatar.dart';
import 'sla_badge.dart';

IconData categoryIcon(String category) {
  switch (category) {
    case 'UI Design':
      return PhosphorIconsRegular.pencilSimple;
    case 'Development':
      return PhosphorIconsRegular.code;
    case 'Testing':
      return PhosphorIconsRegular.bug;
    case 'Documentation':
      return PhosphorIconsRegular.fileText;
    default:
      return PhosphorIconsRegular.listChecks;
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final List<TeamMember> members;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.members,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.surfaceMuted,
                child: Icon(
                  categoryIcon(task.category),
                  size: 20,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              // Expanded lets the text take the free space and shorten.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${task.code} · ${task.category}',
                      style: AppText.secondary,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.cardTitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SlaBadge(status: SlaService.statusFor(task)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ASSIGNEE', style: AppText.caps),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        MemberAvatar(
                          members: members,
                          memberId: task.assigneeId,
                          radius: 10,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            memberName(members, task.assigneeId),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('DUE DATE', style: AppText.caps),
                  const SizedBox(height: 4),
                  Text(formatDate(task.dueDate)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
