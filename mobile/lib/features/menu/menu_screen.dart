import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/shared/widgets/info_card.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              InfoCard(
                title: 'Исполнители',
                icon: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // padding: const EdgeInsets.all(6),
                  child: SvgPicture.asset(
                    'assets/images/menu_stuff.svg',
                    width: 32,
                    height: 32,
                    // colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Main Stats Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Text
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  const Text(
                                    '31',
                                    style: TextStyle(
                                      fontSize: 64,
                                      fontWeight: FontWeight.w400,
                                      height: 1,
                                      fontFamily: 'Yandex Sans Text',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'на линии',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black.withOpacity(0.8),
                                      fontFamily: 'Yandex Sans Text',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildStatusRow(AppTheme.statusGreen, '0 свободно'),
                              const SizedBox(height: 0),
                              _buildStatusRow(AppTheme.statusOrange, '0 на заказе'),
                              const SizedBox(height: 0),
                              _buildStatusRow(AppTheme.statusRed, '31 заняты'),
                            ],
                          ),
                        ),
                        // Chart Placeholder
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 120,
                            child: Stack(
                              children: [
                                // Grid lines
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(4, (index) => Container(height: 1, color: AppTheme.borderColor)),
                                ),
                                // Bar
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    width: 40,
                                    height: 100, // Roughly matching the "30" mark
                                    decoration: BoxDecoration(
                                      color: AppTheme.statusRed,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                // Y-Axis Labels (Roughly)
                                const Positioned(right: 0, top: 0, child: Text('30', style: TextStyle(color: Colors.grey, fontSize: 12))),
                                const Positioned(right: 0, top: 35, child: Text('20', style: TextStyle(color: Colors.grey, fontSize: 12))),
                                const Positioned(right: 0, top: 70, child: Text('10', style: TextStyle(color: Colors.grey, fontSize: 12))),
                                const Positioned(right: 0, bottom: 0, child: Text('0', style: TextStyle(color: Colors.grey, fontSize: 12))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Secondary Stats Grid
                    Row(
                      children: [
                        Expanded(child: _buildInfoBlock('Рейтинг парка ниже среднего', '4,71', icon: Icons.error, iconColor: AppTheme.statusRed)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInfoBlock('Ср. время на линии', '2 ч 28 мин')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildInfoBlock('Новые', '48', subtitle: '+100% ↑', subtitleColor: AppTheme.statusGreen)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInfoBlock('Отток', '2', subtitle: '-50% ↓', subtitleColor: AppTheme.statusGreen)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Yandex Sans Text',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBlock(String title, String value, {IconData? icon, Color? iconColor, String? subtitle, Color? subtitleColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 9, // Small label
              fontWeight: FontWeight.w500,
              fontFamily: 'Yandex Sans Text',
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Yandex Sans Text',
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 6),
                Icon(icon, color: iconColor, size: 20),
              ],
              if (subtitle != null) ...[
                const SizedBox(width: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: subtitleColor,
                    fontFamily: 'Yandex Sans Text',
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
