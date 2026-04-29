import 'package:flutter/material.dart';
import 'package:mobile/features/fleet/presentation/vehicles/vehicles_screen.dart';
import 'package:mobile/features/fleet/presentation/expenses/expenses_screen.dart';
import 'package:mobile/features/fleet/presentation/rents_calendar/rents_calendar_screen.dart';
import 'package:mobile/shared/widgets/fading_button.dart';

class FleetScreen extends StatelessWidget {
  const FleetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Стиль для заголовков разделов
    final sectionStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
      letterSpacing: 1.0,
      fontFamily: 'Yandex Sans Text',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Автопарк'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Text('ОБЪЕКТЫ', style: sectionStyle),
          ),
          AnimatedMenuRow(
            title: 'Автомобили',
            subtitle: 'Список всех ТС',
            icon: Icons.directions_car_filled_rounded,
            iconColor: const Color(0xFF007AFF),
            onTap: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).push(MaterialPageRoute(builder: (_) => VehiclesScreen()));
            },
          ),
          const SizedBox(height: 8),
          AnimatedMenuRow(
            title: 'Гараж',
            subtitle: 'Обслуживание и хранение',
            icon: Icons.garage_rounded,
            iconColor: const Color(0xFF5856D6),
            onTap: () {},
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Text('ФИНАНСЫ', style: sectionStyle),
          ),
          AnimatedMenuRow(
            title: 'Расходы по автомобилям',
            icon: Icons.payments_rounded,
            iconColor: const Color(0xFFFF9500),
            onTap: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).push(MaterialPageRoute(builder: (_) => const ExpensesScreen()));
            },
          ),
          const SizedBox(height: 8),
          AnimatedMenuRow(
            title: 'Штрафы ГИБДД',
            icon: Icons.warning_rounded,
            iconColor: const Color(0xFFFF3B30),
            onTap: () {},
          ),
          const SizedBox(height: 8),
          AnimatedMenuRow(
            title: 'Календарь списаний',
            icon: Icons.calendar_today_rounded,
            iconColor: const Color(0xFF34C759),
            onTap: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).push(MaterialPageRoute(builder: (_) => const RentsCalendarScreen()));
            },
          ),
          const SizedBox(height: 8),
          AnimatedMenuRow(
            title: 'Периодические списания',
            icon: Icons.loop_rounded,
            iconColor: const Color(0xFF30B0C7),
            onTap: () {},
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Text('АНАЛИТИКА', style: sectionStyle),
          ),
          AnimatedMenuRow(
            title: 'Сводка по ТС',
            icon: Icons.summarize_rounded,
            iconColor: const Color(0xFFAF52DE),
            onTap: () {},
          ),
          const SizedBox(height: 8),
          AnimatedMenuRow(
            title: 'Отчёт по ТС',
            icon: Icons.description_rounded,
            iconColor: Colors.blueGrey,
            onTap: () {},
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class AnimatedMenuRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const AnimatedMenuRow({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadingButton(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Yandex Sans Text',
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFamily: 'Yandex Sans Text',
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
