import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/menu/providers/cars_provider.dart';
import 'package:mobile/features/menu/widgets/cars_chart.dart';
import 'package:mobile/features/menu/widgets/menu_icon.dart';
import 'package:mobile/shared/widgets/big_stat.dart';
import 'package:mobile/shared/widgets/pulse_box.dart';
import 'package:mobile/shared/widgets/info_card.dart';
import 'package:mobile/shared/widgets/status_list.dart';

class CarsCard extends ConsumerWidget {
  const CarsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carsAsync = ref.watch(carsDataProvider);

    return InfoCard(
      title: 'Автомобили',
      icon: const MenuIcon(assetPath: 'assets/images/menu_auto.svg'),
      child: carsAsync.when(
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BigStat(
              value: _formatNumber(data.indicator.total),
              label: 'парковых автомобилей',
              isFlexibleLabel: true,
            ),
            const SizedBox(height: 16),
            StatusList(
              items: [
                (
                  color: AppTheme.statusGreen,
                  text:
                      '${data.indicator.working.count} ${data.indicator.working.name.toLowerCase()}',
                  onTap: null,
                ),
                (
                  color: AppTheme.statusOrange,
                  text:
                      '${data.indicator.noDriver.count} ${data.indicator.noDriver.name.toLowerCase()}',
                  onTap: null,
                ),
                (
                  color: AppTheme.statusRed,
                  text:
                      '${data.indicator.repairing.count} ${data.indicator.repairing.name.toLowerCase()}',
                  onTap: null,
                ),
                (
                  color: AppTheme.statusBlue,
                  text:
                      '${data.indicator.pending.count} ${data.indicator.pending.name.toLowerCase()}',
                  onTap: null,
                ),
                (
                  color: Colors.grey,
                  text:
                      '${data.indicator.unknown.count} ${data.indicator.unknown.name.toLowerCase()}',
                  onTap: null,
                ),
              ],
            ),
            const SizedBox(height: 24),
            CarsChart(indicator: data.indicator),
          ],
        ),
        loading: () => const _CarsSkeleton(),
        error: (error, stack) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text(
                'Ошибка загрузки данных',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }
}

class _CarsSkeleton extends StatelessWidget {
  const _CarsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PulseBox(width: 80, height: 44, borderRadius: 10),
        const SizedBox(height: 6),
        const PulseBox(width: 120, height: 12, borderRadius: 4),
        const SizedBox(height: 18),
        for (final w in [130.0, 115.0, 120.0, 100.0, 110.0]) ...[  
          PulseBox(width: w, height: 14, borderRadius: 6),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 16),
        const PulseBox(height: 120, borderRadius: 12),
      ],
    );
  }
}
