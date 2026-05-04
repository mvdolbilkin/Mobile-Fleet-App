import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/menu/providers/contractors_provider.dart';
import 'package:mobile/features/menu/widgets/executors_chart.dart';
import 'package:mobile/features/menu/widgets/menu_icon.dart';
import 'package:mobile/shared/widgets/big_stat.dart';
import 'package:mobile/shared/widgets/info_block.dart';
import 'package:mobile/shared/widgets/info_card.dart';
import 'package:mobile/shared/widgets/status_list.dart';

class ExecutorsCard extends ConsumerWidget {
  const ExecutorsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractorsAsync = ref.watch(contractorsDataProvider);

    return InfoCard(
      title: 'Исполнители',
      icon: const MenuIcon(assetPath: 'assets/images/menu_stuff.svg'),
      onTap: () => context.go('/staff'),
      child: contractorsAsync.when(
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BigStat(
                        value: '${data.indicator.total}',
                        label: 'на линии',
                      ),
                      const SizedBox(height: 16),
                      StatusList(
                        items: [
                          (
                            color: AppTheme.statusGreen,
                            text: '${data.indicator.free} свободно',
                            onTap: () => context.go('/staff?status=free'),
                          ),
                          (
                            color: AppTheme.statusOrange,
                            text: '${data.indicator.inOrder} на заказе',
                            onTap: () => context.go('/staff?status=in_order'),
                          ),
                          (
                            color: AppTheme.statusRed,
                            text: '${data.indicator.busy} заняты',
                            onTap: () => context.go('/staff?status=busy'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(child: ExecutorsChart(indicator: data.indicator)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: InfoBlock(
                    title: data.ratingInfo.ratingCategory.text,
                    value: data.ratingInfo.rating,
                    iconAsset: 'assets/images/menu_stuff_rating.svg',
                    iconColor: data.ratingInfo.ratingCategory.isBelowAverage
                        ? AppTheme.statusRed
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InfoBlock(
                    title: 'Ср. время на линии',
                    value: data.avgTimeOnline.formatted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InfoBlock(
                    title: 'Новые',
                    value: '${data.newContractors.current.toInt()}',
                    subtitle:
                        '${data.newContractors.diff.formattedValue} ${data.newContractors.diff.arrow}',
                    subtitleColor: data.newContractors.diff.value >= 0
                        ? AppTheme.statusGreen
                        : AppTheme.statusRed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InfoBlock(
                    title: 'Отток',
                    value: '${data.churn.current.toInt()}',
                    subtitle:
                        '${data.churn.diff.formattedValue} ${data.churn.diff.arrow}',
                    subtitleColor: data.churn.diff.value <= 0
                        ? AppTheme.statusGreen
                        : AppTheme.statusRed,
                  ),
                ),
              ],
            ),
          ],
        ),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
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
}
