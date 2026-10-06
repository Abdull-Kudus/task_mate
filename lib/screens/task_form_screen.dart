import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskFormScreen extends StatelessWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Form')),
      body: const Center(child: Text('Coming soon')),
    );
  }
}
