import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile/features/fleet/presentation/vehicles/vehicles_screen.dart';
import 'package:mobile/features/fleet/presentation/expenses/expenses_screen.dart';
import 'package:mobile/features/fleet/presentation/rents_calendar/rents_calendar_screen.dart';
import 'package:mobile/features/fleet/presentation/garage/garage_screen.dart';
import 'package:mobile/features/fleet/presentation/regular_charges/regular_charges_screen.dart';
import 'package:mobile/features/fleet/presentation/fines/fines_screen.dart';
import 'package:mobile/features/fleet/presentation/summary/summary_screen.dart';
import 'package:mobile/features/fleet/presentation/car_efficiency/car_efficiency_screen.dart';
import 'package:mobile/shared/widgets/fading_button.dart';

class FleetScreen extends StatelessWidget {
  const FleetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Автопарк'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _SectionHeader(title: 'ОБЪЕКТЫ'),
          _SectionCard(
            children: [
              _MenuRow(
                title: 'Автомобили',
                subtitle: 'Список всех ТС',
                icon: HugeIcons.strokeRoundedCar01,
                onTap: () => Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (_) => VehiclesScreen())),
              ),
              const _RowDivider(),
              _MenuRow(
                title: 'Гараж',
                subtitle: 'Обслуживание и хранение',
                icon: HugeIcons.strokeRoundedGarage,
                onTap: () => Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (_) => const GarageScreen())),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _SectionHeader(title: 'ФИНАНСЫ'),
          _SectionCard(
            children: [
              _MenuRow(
                title: 'Расходы по автомобилям',
                icon: HugeIcons.strokeRoundedMoney02,
                onTap: () => Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (_) => const ExpensesScreen())),
              ),
              const _RowDivider(),
              _MenuRow(
                title: 'Штрафы ГИБДД',
                icon: HugeIcons.strokeRoundedAlert02,
                onTap: () => Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (_) => const FinesScreen())),
              ),
              const _RowDivider(),
              _MenuRow(
                title: 'Календарь списаний',
                icon: HugeIcons.strokeRoundedCalendar03,
                onTap: () => Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (_) => const RentsCalendarScreen())),
              ),
              const _RowDivider(),
              _MenuRow(
                title: 'Периодические списания',
                icon: HugeIcons.strokeRoundedRepeat,
                onTap: () => Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (_) => const RegularChargesScreen())),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _SectionHeader(title: 'АНАЛИТИКА'),
          _SectionCard(
            children: [
              _MenuRow(
                title: 'Сводка по ТС',
                icon: HugeIcons.strokeRoundedAnalytics02,
                onTap: () => Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (_) => const FleetSummaryScreen())),
              ),
              const _RowDivider(),
              _MenuRow(
                title: 'Отчёт по ТС',
                icon: HugeIcons.strokeRoundedFile02,
                onTap: () => Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (_) => const CarEfficiencyScreen())),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.8,
          fontFamily: 'Yandex Sans Text',
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final dynamic icon;
  final VoidCallback onTap;

  const _MenuRow({
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.onSurfaceVariant;

    return FadingButton(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            HugeIcon(
              icon: icon,
              color: iconColor,
              size: 24,
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
                    const SizedBox(height: 2),
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
              size: 20,
              color: theme.colorScheme.outline.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}
