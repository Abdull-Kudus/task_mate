import '../models/task.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

const _weekdays = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday',
  'Friday', 'Saturday', 'Sunday',
];

// 8 Oct 2026
String formatDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

// Tuesday, 6 Oct 2026
String formatLongDate(DateTime date) =>
    '${_weekdays[date.weekday - 1]}, ${formatDate(date)}';

String statusLabel(TaskStatus status) {
  switch (status) {
    case TaskStatus.todo:
      return 'To Do';
    case TaskStatus.inProgress:
      return 'In Progress';
    case TaskStatus.done:
      return 'Done';
  }
}

String priorityLabel(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.low:
      return 'Low';
    case TaskPriority.medium:
      return 'Medium';
    case TaskPriority.high:
      return 'High';
  }
}
