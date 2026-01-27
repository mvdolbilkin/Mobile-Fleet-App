import 'package:flutter/material.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/menu/widgets/executors_chart.dart';
import 'package:mobile/features/menu/widgets/menu_icon.dart';
import 'package:mobile/shared/widgets/big_stat.dart';
import 'package:mobile/shared/widgets/info_block.dart';
import 'package:mobile/shared/widgets/info_card.dart';
import 'package:mobile/shared/widgets/status_list.dart';

class ExecutorsCard extends StatelessWidget {
  const ExecutorsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'Исполнители',
      icon: const MenuIcon(assetPath: 'assets/images/menu_stuff.svg'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BigStat(
                      value: '31',
                      label: 'на линии',
                    ),
                    const SizedBox(height: 16),
                    StatusList(
                      items: [
                        (color: AppTheme.statusGreen, text: '0 свободно'),
                        (color: AppTheme.statusOrange, text: '0 на заказе'),
                        (color: AppTheme.statusRed, text: '31 заняты'),
                      ],
                    ),
                  ],
                ),
              ),
              const Expanded(
                flex: 2,
                child: ExecutorsChart(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: InfoBlock(
                  title: 'Рейтинг парка ниже среднего',
                  value: '4,71',
                  iconAsset: 'assets/images/menu_stuff_rating.svg',
                  iconColor: AppTheme.statusRed,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: InfoBlock(
                  title: 'Ср. время на линии',
                  value: '2 ч 28 мин',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: InfoBlock(
                  title: 'Новые',
                  value: '48',
                  subtitle: '+100% ↑',
                  subtitleColor: AppTheme.statusGreen,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: InfoBlock(
                  title: 'Отток',
                  value: '2',
                  subtitle: '-50% ↓',
                  subtitleColor: AppTheme.statusGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
