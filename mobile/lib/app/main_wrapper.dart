import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _goBranch,
          destinations: [
            NavigationDestination(
              icon: SvgPicture.asset('assets/images/autopark.svg', width: 24, height: 24),
              selectedIcon: SvgPicture.asset('assets/images/autopark_selected.svg', width: 24, height: 24),
              label: 'Автопарк',
            ),
            NavigationDestination(
              icon: SvgPicture.asset('assets/images/personal.svg', width: 24, height: 24),
              selectedIcon: SvgPicture.asset('assets/images/personal_selected.svg', width: 24, height: 24),
              label: 'Персонал',
            ),
            NavigationDestination(
              icon: SvgPicture.asset('assets/images/map.svg', width: 24, height: 24),
              selectedIcon: SvgPicture.asset('assets/images/map_selected.svg', width: 24, height: 24),
              label: 'Карта',
            ),
            NavigationDestination(
              icon: SvgPicture.asset('assets/images/analytics.svg', width: 24, height: 24),
              selectedIcon: SvgPicture.asset('assets/images/analytics_selected.svg', width: 24, height: 24),
              label: 'Аналитика',
            ),
            NavigationDestination(
              icon: SvgPicture.asset('assets/images/menu.svg', width: 20, height: 20),
              selectedIcon: SvgPicture.asset('assets/images/menu_selected.svg', width: 24, height: 24),
              label: 'Меню',
            ),
          ],
        ),
      ),
    );
  }
}
