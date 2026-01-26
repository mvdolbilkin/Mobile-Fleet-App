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
                                      fontSize: 40,
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
                              _buildDynamicStatusList([
                                (color: AppTheme.statusGreen, text: '0 свободно'),
                                (color: AppTheme.statusOrange, text: '0 на заказе'),
                                (color: AppTheme.statusRed, text: '31 заняты'),
                              ]),
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
                        Expanded(child: _buildInfoBlock('Рейтинг парка ниже среднего', '4,71', iconAsset: 'assets/images/menu_stuff_rating.svg', iconColor: AppTheme.statusRed)),
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
              const SizedBox(height: 16),
              InfoCard(
                title: 'Автомобили',
                icon: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // padding: const EdgeInsets.all(6),
                  child: SvgPicture.asset(
                    'assets/images/menu_auto.svg',
                    width: 32,
                    height: 32,
                    // colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          '2 467',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w400,
                            height: 1,
                            fontFamily: 'Yandex Sans Text',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'парковых автомобилей',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xCC000000), // ~80% opacity
                              fontFamily: 'Yandex Sans Text',
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDynamicStatusList([
                      (color: AppTheme.statusGreen, text: '2 382 работает'),
                      (color: AppTheme.statusOrange, text: '67 нет водителя'),
                      (color: AppTheme.statusRed, text: '1 сервис'),
                      (color: AppTheme.statusBlue, text: '1 подготовка'),
                      (color: Colors.grey, text: '16 другое'),
                    ]),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 180,
                      child: Stack(
                        children: [
                          // Grid lines and Labels
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildChartLine('2 тыс.'),
                              _buildChartLine('1 тыс.'),
                              _buildChartLine('0'),
                            ],
                          ),
                          // Bars
                          Positioned(
                            bottom: 25, // Start from the '0' line (approx text height + padding)
                            left: 0,
                            right: 50, // Leave space for right-side labels? Ah, labels are on right in mockup
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const SizedBox(width: 40), // Left padding
                                Container(
                                  width: 60,
                                  height: 140, // Visual approximation for > 2000
                                  decoration: const BoxDecoration(
                                    color: AppTheme.statusGreen,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 60,
                                  height: 6, // Visual approximation for ~67
                                  decoration: const BoxDecoration(
                                    color: AppTheme.statusOrange,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildDynamicStatusList(List<({Color color, String text})> items) {
    if (items.length > 3) {
      return Wrap(
        spacing: 12,
        runSpacing: 8,
        children: items
            .map((item) => _buildStatusRow(item.color, item.text))
            .toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: _buildStatusRow(item.color, item.text),
              ))
          .toList(),
    );
  }

  Widget _buildStatusRow(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: 'Yandex Sans Text',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBlock(String title, String value,
      {IconData? icon,
      String? iconAsset,
      Color? iconColor,
      String? subtitle,
      Color? subtitleColor}) {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Yandex Sans Text',
                  height: 1.2,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 6),
                Icon(icon, color: iconColor, size: 20),
              ] else if (iconAsset != null) ...[
                const SizedBox(width: 3),
                SvgPicture.asset(
                  iconAsset,
                  width: 16,
                  height: 16,
                  colorFilter: iconColor != null
                      ? ColorFilter.mode(iconColor, BlendMode.srcIn)
                      : null,
                ),
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

  Widget _buildChartLine(String label) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppTheme.borderColor)),
        const SizedBox(width: 8),
        SizedBox(
          width: 40, // Fixed width for labels
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9E9E9E), // Colors.grey
              fontSize: 12,
              fontFamily: 'Yandex Sans Text',
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
