import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'pro_dashboard_screen.dart';
import '../pro_active_work/pro_active_work_screen.dart';
import '../pro_profile/pro_profile_screen.dart';

class ProShellScreen extends StatefulWidget {
  final int initialTab;
  const ProShellScreen({super.key, this.initialTab = 0});

  @override
  State<ProShellScreen> createState() => _ProShellScreenState();
}

class _ProShellScreenState extends State<ProShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  final List<Widget> _pages = const [
    ProDashboardScreen(),
    ProActiveWorkScreen(),
    ProProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withOpacity(0.12),
          elevation: 0,
          onDestinationSelected: (idx) {
            setState(() {
              _currentIndex = idx;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.work_outline_rounded),
              selectedIcon:
                  Icon(Icons.work_rounded, color: AppColors.primary),
              label: 'İş Fırsatları',
            ),
            NavigationDestination(
              icon: Icon(Icons.build_outlined),
              selectedIcon:
                  Icon(Icons.build_rounded, color: AppColors.primary),
              label: 'Aktif İşim',
            ),
            NavigationDestination(
              icon: Icon(Icons.badge_outlined),
              selectedIcon:
                  Icon(Icons.badge_rounded, color: AppColors.primary),
              label: 'Usta Profilim',
            ),
          ],
        ),
      ),
    );
  }
}
