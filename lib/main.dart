import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'screens/sign_in_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.seedIfEmpty();
  final userId = await StorageService.getCurrentUserId();

  runApp(TaskMateApp(initialUserId: userId));
}

class TaskMateApp extends StatelessWidget {
  final String? initialUserId;

  const TaskMateApp({super.key, this.initialUserId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskMate',
      theme: AppTheme.light,
      home: initialUserId != null ? const HomeShell() : const SignInScreen(),
    );
  }
}
