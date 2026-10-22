import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'customer_home_screen.dart';
import '../customer_jobs/my_jobs_screen.dart';
import '../customer_profile/customer_profile_screen.dart';

class CustomerShellScreen extends StatefulWidget {
  final int initialTab;
  const CustomerShellScreen({super.key, this.initialTab = 0});

  @override
  State<CustomerShellScreen> createState() => _CustomerShellScreenState();
}

class _CustomerShellScreenState extends State<CustomerShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  final List<Widget> _pages = const [
    CustomerHomeScreen(),
    MyJobsScreen(),
    CustomerProfileScreen(),
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
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon:
                  const Icon(Icons.explore_rounded, color: AppColors.primary),
              label: 'Keşfet',
            ),
            NavigationDestination(
              icon: const Icon(Icons.assignment_outlined),
              selectedIcon: const Icon(Icons.assignment_rounded,
                  color: AppColors.primary),
              label: 'Taleplerim',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon:
                  const Icon(Icons.person_rounded, color: AppColors.primary),
              label: 'Profilim',
            ),
          ],
        ),
      ),
    );
  }
}
