import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'task_list_screen.dart';
import 'team_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardScreen(onSeeAllTasks: () => setState(() => _index = 1)),
      const TaskListScreen(),
      const TeamScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.outline)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (index) => setState(() => _index = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(PhosphorIconsRegular.house),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(PhosphorIconsRegular.listChecks),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(PhosphorIconsRegular.usersThree),
              label: 'Team',
            ),
            NavigationDestination(
              icon: Icon(PhosphorIconsRegular.user),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
