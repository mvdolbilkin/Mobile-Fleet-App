import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/summary/providers/summary_provider.dart';
import 'package:mobile/features/summary/models/active_drivers_model.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  void _copyClid(BuildContext context, String clid) {
    Clipboard.setData(ClipboardData(text: clid));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clid скопирован')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(parkProfileProvider);
    final activeDriversAsync = ref.watch(activeDriversProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Сводка'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              profileAsync.when(
                data: (data) {
                  final park = data.park;
                  final timeSign = park.timezoneOffset >= 0 ? '+' : '-';
                  final absOffset = park.timezoneOffset.abs().toString().padLeft(2, '0');
                  final offsetStr = '$timeSign$absOffset:00';

                  return Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          park.name,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Yandex Sans Text',
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Clid ${park.clid}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Yandex Sans Text',
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _copyClid(context, park.clid),
                              child: const Icon(
                                Icons.copy_outlined,
                                size: 20,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 64),
                        Text(
                          '${park.city.name}, $offsetStr, Данные отображаются\nс задержкой до 1 часа',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Yandex Sans Text',
                            color: AppTheme.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text('Ошибка загрузки данных:\n$err', textAlign: TextAlign.center),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Активность',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Yandex Sans Text',
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    activeDriversAsync.when(
                      data: (data) => _ActiveDriversChart(data: data),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (err, stack) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text('Ошибка загрузки данных:\n$err', textAlign: TextAlign.center),
                        ),
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
}

class _ActiveDriversChart extends StatelessWidget {
  final ActiveDriversResponse data;

  const _ActiveDriversChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.series.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Нет данных')),
      );
    }

    final commonSeries = data.series.firstWhere(
      (element) => element.id == 'common',
      orElse: () => ActiveDriversSeries(id: 'common'),
    );

    if (commonSeries.requested == null || commonSeries.requested!.chart.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Нет данных графика')),
      );
    }

    final requestedChart = _getSpots(commonSeries.requested!.chart);
    final previousChart = commonSeries.previous != null
        ? _getSpots(commonSeries.previous!.chart)
        : <FlSpot>[];

    double maxY = 0;
    for (var spot in requestedChart) {
      if (spot.y > maxY) maxY = spot.y;
    }
    for (var spot in previousChart) {
      if (spot.y > maxY) maxY = spot.y;
    }
    // Add some padding to the max value
    maxY = maxY > 0 ? maxY * 1.2 : 10;

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Color(0xFFF2F2F2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: maxY / 4,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Yandex Sans Text',
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
                  final index = value.toInt();
                  if (index >= 0 && index < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[index],
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontFamily: 'Yandex Sans Text',
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            if (previousChart.isNotEmpty)
              LineChartBarData(
                spots: previousChart,
                isCurved: true,
                color: const Color(0x7F9E9E9E),
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            LineChartBarData(
              spots: requestedChart,
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getSpots(List<ChartPoint> chart) {
    if (chart.isEmpty) return [];
    
    List<FlSpot> spots = [];
    for (int i = 0; i < chart.length; i++) {
      spots.add(FlSpot(i.toDouble(), chart[i].y));
    }
    return spots;
  }
}

