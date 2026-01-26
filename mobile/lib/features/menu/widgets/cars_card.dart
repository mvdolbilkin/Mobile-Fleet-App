import 'package:flutter/material.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/menu/widgets/cars_chart.dart';
import 'package:mobile/features/menu/widgets/menu_icon.dart';
import 'package:mobile/shared/widgets/big_stat.dart';
import 'package:mobile/shared/widgets/info_card.dart';
import 'package:mobile/shared/widgets/status_list.dart';

class CarsCard extends StatelessWidget {
  const CarsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'Автомобили',
      icon: const MenuIcon(assetPath: 'assets/images/menu_auto.svg'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BigStat(
            value: '2 467',
            label: 'парковых автомобилей',
            isFlexibleLabel: true,
          ),
          const SizedBox(height: 16),
          StatusList(
            items: [
              (color: AppTheme.statusGreen, text: '2 382 работает'),
              (color: AppTheme.statusOrange, text: '67 нет водителя'),
              (color: AppTheme.statusRed, text: '1 сервис'),
              (color: AppTheme.statusBlue, text: '1 подготовка'),
              (color: Colors.grey, text: '16 другое'),
            ],
          ),
          const SizedBox(height: 24),
          const CarsChart(),
        ],
      ),
    );
  }
}
