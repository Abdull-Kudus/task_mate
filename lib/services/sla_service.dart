import '../models/task.dart';
import '../utils/formatters.dart';

enum SlaStatus { onTrack, atRisk, overdue, completed }

class SlaService {
  // How early a task is flagged, based on its priority.
  static Duration riskWindow(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return const Duration(hours: 72);
      case TaskPriority.medium:
        return const Duration(hours: 48);
      case TaskPriority.low:
        return const Duration(hours: 24);
    }
  }

  // A task is due at the end of its due day.
  static DateTime deadline(Task task) => DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
        23,
        59,
        59,
      );

  // First rule that matches wins. `now` can be passed in for testing.
  static SlaStatus statusFor(Task task, {DateTime? now}) {
    final current = now ?? DateTime.now();
    if (task.status == TaskStatus.done) return SlaStatus.completed;
    if (current.isAfter(deadline(task))) return SlaStatus.overdue;
    final timeLeft = deadline(task).difference(current);
    if (timeLeft <= riskWindow(task.priority)) return SlaStatus.atRisk;
    return SlaStatus.onTrack;
  }

  static String _count(int n, String word) =>
      n == 1 ? '1 $word' : '$n ${word}s';

  // The sentence shown on the SLA card in Task Details.
  static String explain(Task task, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final hours = riskWindow(task.priority).inHours;
    final daysLeft = deadline(task).difference(current).inDays;
    final dueIn = daysLeft == 0 ? 'less than a day' : _count(daysLeft, 'day');

    switch (statusFor(task, now: current)) {
      case SlaStatus.completed:
        return 'Completed: this task is marked Done.';
      case SlaStatus.overdue:
        final daysLate = current.difference(deadline(task)).inDays;
        final late =
            daysLate == 0 ? 'less than a day' : _count(daysLate, 'day');
        return 'Overdue: the deadline passed $late ago.';
      case SlaStatus.atRisk:
        return 'At Risk: due in $dueIn. ${priorityLabel(task.priority)} '
            'priority tasks are flagged $hours hours before the deadline.';
      case SlaStatus.onTrack:
        return 'On Track: due in $dueIn. It will be flagged $hours hours '
            'before the deadline.';
    }
  }
}
