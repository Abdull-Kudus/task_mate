import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../services/sla_service.dart';

class SlaStyle {
  final String label;
  final Color color;
  final Color background;
  final IconData icon;

  const SlaStyle(this.label, this.color, this.background, this.icon);
}

// One place that decides how each SLA status looks.
SlaStyle slaStyleFor(SlaStatus status) {
  switch (status) {
    case SlaStatus.onTrack:
      return const SlaStyle('On Track', Color(0xFF1E7A34), Color(0xFFE3F6E3),
          PhosphorIconsRegular.checkCircle);
    case SlaStatus.atRisk:
      return const SlaStyle('At Risk', Color(0xFF8A5A00), Color(0xFFFFF1CC),
          PhosphorIconsRegular.warning);
    case SlaStatus.overdue:
      return const SlaStyle('Overdue', Color(0xFFB3261E), Color(0xFFFDE7E5),
          PhosphorIconsRegular.warningCircle);
    case SlaStatus.completed:
      return const SlaStyle('Completed', Color(0xFF44546A), Color(0xFFE6EAF0),
          PhosphorIconsRegular.checkSquareOffset);
  }
}

class SlaBadge extends StatelessWidget {
  final SlaStatus status;

  const SlaBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final style = slaStyleFor(status);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 16, color: style.color),
          const SizedBox(width: 4),
          Text(
            style.label,
            style: TextStyle(
              color: style.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
