import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:holyroad/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:holyroad/features/admin/presentation/screens/admin_sites_screen.dart';
import 'package:holyroad/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:holyroad/features/admin/presentation/screens/admin_moderation_screen.dart';

class AdminShellScreen extends StatefulWidget {
  final int initialTab;
  const AdminShellScreen({super.key, this.initialTab = 0});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

  static const _screens = [
    AdminDashboardScreen(),
    AdminSitesScreen(),
    AdminUsersScreen(),
    AdminModerationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            extended: MediaQuery.of(context).size.width > 1100,
            backgroundColor: colorScheme.surface,
            indicatorColor: colorScheme.primaryContainer,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Icon(Icons.church, size: 32, color: colorScheme.primary),
                  const SizedBox(height: 4),
                  Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: '앱으로 돌아가기',
                    onPressed: () => context.go('/'),
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('대시보드'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.place_outlined),
                selectedIcon: Icon(Icons.place),
                label: Text('성지 관리'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outlined),
                selectedIcon: Icon(Icons.people),
                label: Text('사용자'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.rate_review_outlined),
                selectedIcon: Icon(Icons.rate_review),
                label: Text('모더레이션'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }
}
