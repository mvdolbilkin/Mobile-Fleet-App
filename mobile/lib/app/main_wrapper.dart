import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/app/theme.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Widget _buildIcon(BuildContext context, String path, Color color) {
    final double size = 28.0;
    return SvgPicture.asset(
      path,
      fit: BoxFit.contain,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
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
              icon: _buildIcon(context, 'assets/images/autopark.svg', AppTheme.textSecondary),
              selectedIcon: _buildIcon(context, 'assets/images/autopark.svg', Colors.black),
              label: 'Автопарк',
            ),
            NavigationDestination(
              icon: _buildIcon(context, 'assets/images/personal.svg', AppTheme.textSecondary),
              selectedIcon: _buildIcon(context, 'assets/images/personal.svg', Colors.black),
              label: 'Персонал',
            ),
            NavigationDestination(
              icon: _buildIcon(context, 'assets/images/map.svg', AppTheme.textSecondary),
              selectedIcon: _buildIcon(context, 'assets/images/map.svg', Colors.black),
              label: 'Карта',
            ),
            NavigationDestination(
              icon: _buildIcon(context, 'assets/images/analytics.svg', AppTheme.textSecondary),
              selectedIcon: _buildIcon(context, 'assets/images/analytics.svg', Colors.black),
              label: 'Аналитика',
            ),
            NavigationDestination(
              icon: _buildIcon(context, 'assets/images/menu.svg', AppTheme.textSecondary),
              selectedIcon: _buildIcon(context, 'assets/images/menu.svg', Colors.black),
              label: 'Меню',
            ),
          ],
        ),
      ),
    );
  }
}
