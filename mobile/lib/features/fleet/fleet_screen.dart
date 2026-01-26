import 'package:flutter/material.dart';
import 'package:mobile/features/fleet/presentation/vehicles/vehicles_screen.dart';
import 'package:mobile/shared/widgets/animated_icon_button.dart';
import '../../app/theme.dart';

class FleetScreen extends StatelessWidget {
  const FleetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Автопарк'),
        
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _MenuItem(
              title: 'Автомобили',
              icon: Icons.directions_car,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VehiclesScreen()),
                );
              },
            ),
            _MenuItem(
              title: 'Календарь списаний',
              icon: Icons.calendar_today,
              onTap: () {},
            ),
            _MenuItem(
              title: 'Расходы по автомобилям',
              icon: Icons.payments,
              onTap: () {},
            ),
            _MenuItem(
              title: 'Периодические списания',
              icon: Icons.loop,
              onTap: () {},
            ),
            _MenuItem(
              title: 'Штрафы ГИБДД',
              icon: Icons.warning,
              onTap: () {},
            ),
            _MenuItem(
              title: 'Сводка по ТС',
              icon: Icons.summarize,
              onTap: () {},
            ),
            _MenuItem(
              title: 'Отчёт по ТС',
              icon: Icons.description,
              onTap: () {},
            ),
            _MenuItem(
              title: 'Гараж',
              icon: Icons.garage,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppTheme.primaryColor),
            SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
