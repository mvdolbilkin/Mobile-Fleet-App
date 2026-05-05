import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/fleet/domain/cars_mileage_model.dart';
import 'package:mobile/features/fleet/domain/cars_statuses_model.dart';
import 'package:mobile/features/fleet/providers/fleet_summary_provider.dart';
import 'package:mobile/shared/widgets/fading_button.dart';

class FleetSummaryScreen extends ConsumerStatefulWidget {
  const FleetSummaryScreen({super.key});

  @override
  ConsumerState<FleetSummaryScreen> createState() => _FleetSummaryScreenState();
}

class _FleetSummaryScreenState extends ConsumerState<FleetSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сводка по ТС'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          const _VehiclesSummaryCard(),
          const SizedBox(height: 12),
          const _CarsStatusesCard(),
          const SizedBox(height: 12),
          const _MileageCard(),
          const SizedBox(height: 12),
          const _HoursOnlineCard(),
          const SizedBox(height: 12),
          const _AcceptanceRateCard(),
          const SizedBox(height: 12),
          const _TripsCard(),
        ],
      ),
    );
  }
}

class _VehiclesSummaryCard extends StatelessWidget {
  const _VehiclesSummaryCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'ТС',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Yandex Sans Text',
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.help_outline,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ],
                ),
                FadingButton(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        'Отчёт',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Yandex Sans Text',
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Total Stats
            _StatRow(
              value: '1 925',
              diffValue: 20,
              isPositive: true,
              showDiff: true,
            ),
            
            const SizedBox(height: 12),
            Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
            const SizedBox(height: 12),
            
            // Online
            _ActionLabel(
              label: 'На линии',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _StatRow(
              value: '13',
              diffValue: 0,
              showDiff: false,
            ),
            
            const SizedBox(height: 12),
            Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
            const SizedBox(height: 12),
            
            // Offline
            _ActionLabel(
              label: 'Не на линии',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _StatRow(
              value: '1 912',
              diffValue: 20,
              isPositive: false,
              showDiff: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String value;
  final int diffValue;
  final bool isPositive;
  final bool showDiff;

  const _StatRow({
    required this.value,
    required this.diffValue,
    this.isPositive = true,
    this.showDiff = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w400,
            height: 1,
            fontFamily: 'Yandex Sans Text',
          ),
        ),
        if (showDiff && diffValue != 0) ...[
          const SizedBox(width: 8),
          Text(
            '+$diffValue',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isPositive ? const Color(0xFF00B341) : const Color(0xFFE64646),
              fontFamily: 'Yandex Sans Text',
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_upward,
            size: 18,
            color: isPositive ? const Color(0xFF00B341) : const Color(0xFFE64646),
          ),
        ],
      ],
    );
  }
}

class _ActionLabel extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionLabel({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadingButton(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontFamily: 'Yandex Sans Text',
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            Icons.chevron_right,
            size: 18,
            color: theme.colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}

String _fmtTooltipDate(String xStr) {
  if (xStr.length < 10) return '';
  try {
    final d = DateTime.parse(xStr.substring(0, 10));
    const days = ['понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота', 'воскресенье'];
    const months = ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
  } catch (_) {
    return '';
  }
}

// ─── Карточка "Статусы" ──────────────────────────────────────────────────────

class _CarsStatusesCard extends ConsumerWidget {
  const _CarsStatusesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(carsStatusesProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Статусы',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Yandex Sans Text',
                ),
              ),
              FadingButton(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      'Отчёт',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Yandex Sans Text',
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          async.when(
            loading: () => const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'Ошибка загрузки',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'Yandex Sans Text',
                  ),
                ),
              ),
            ),
            data: (data) => _StatusesChartContent(data: data),
          ),
        ],
      ),
    );
  }
}

class _StatusesChartContent extends StatelessWidget {
  final CarsStatusesResponse data;

  const _StatusesChartContent({required this.data});

  static Color _colorFor(String id) {
    switch (id) {
      case 'working':
        return const Color(0xFF21A64F);
      case 'no_driver':
        return const Color(0xFFF5A623);
      case 'service':
        return const Color(0xFFE63535);
      case 'preparing':
        return const Color(0xFF2979FF);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data.series.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('Нет данных')),
      );
    }

    // Compute maxY across all series
    double maxY = 0;
    for (final s in data.series) {
      for (final p in s.values) {
        if (p.y > maxY) maxY = p.y;
      }
    }
    if (maxY == 0) maxY = 10;
    final maxYPadded = maxY * 1.1;

    // Build line bars
    final lineBars = data.series.map((s) {
      final spots = <FlSpot>[];
      for (int i = 0; i < s.values.length; i++) {
        spots.add(FlSpot(i.toDouble(), s.values[i].y));
      }
      return LineChartBarData(
        spots: spots,
        isCurved: false,
        color: _colorFor(s.id),
        barWidth: 1.5,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      );
    }).toList();

    final pointCount = data.series.isNotEmpty ? data.series.first.values.length : 30;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: data.series.map((s) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _colorFor(s.id),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  s.name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Yandex Sans Text',
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (pointCount - 1).toDouble(),
              minY: 0,
              maxY: maxYPadded,
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                verticalInterval: 5,
                horizontalInterval: maxYPadded / 4,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: Color(0xFFEEEEEE),
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (_) => const FlLine(
                  color: Color(0xFFEEEEEE),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    interval: maxYPadded / 4,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) {
                        return const Text('0',
                            style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF999999),
                                fontFamily: 'Yandex Sans Text'));
                      }
                      final v = value >= 1000
                          ? '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)} тыс.'
                          : value.toInt().toString();
                      return Text(v,
                          style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF999999),
                              fontFamily: 'Yandex Sans Text'));
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= data.series.first.values.length) {
                        return const SizedBox.shrink();
                      }
                      final dateStr = data.series.first.values[idx].x;
                      if (dateStr.length >= 10) {
                        final day = int.tryParse(dateStr.substring(8, 10)) ?? 0;
                        if (day % 5 != 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '$day',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF999999),
                              fontFamily: 'Yandex Sans Text',
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => Colors.white,
                  tooltipBorder: const BorderSide(color: Color(0xFFE0E0E0)),

                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spots) => spots.map((spot) {
                    final barIdx = spot.barIndex;
                    if (barIdx >= data.series.length) return null;
                    final series = data.series[barIdx];
                    final idx = spot.x.toInt();
                    final date = idx >= 0 && idx < series.values.length
                        ? _fmtTooltipDate(series.values[idx].x) : '';
                    final color = _colorFor(series.id);
                    return LineTooltipItem(
                      '● ${spot.y.toInt()} ',
                      TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Yandex Sans Text'),
                      children: [TextSpan(text: date, style: const TextStyle(color: Color(0xFF333333), fontSize: 12, fontWeight: FontWeight.normal, fontFamily: 'Yandex Sans Text'))],
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: lineBars,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Карточка "Пробег на ТС на линии" ────────────────────────────────────────

class _MileageCard extends ConsumerWidget {
  const _MileageCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(carsMileageProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Пробег на ТС на линии',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Yandex Sans Text',
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.help_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ],
              ),
              FadingButton(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      'Отчёт',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Yandex Sans Text',
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          async.when(
            loading: () => const SizedBox(
              height: 260,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  'Ошибка загрузки',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'Yandex Sans Text',
                  ),
                ),
              ),
            ),
            data: (data) => _MileageChartContent(data: data),
          ),
        ],
      ),
    );
  }
}

class _MileageChartContent extends StatelessWidget {
  final CarsMileageResponse data;

  const _MileageChartContent({required this.data});

  static String _fmtKm(double v) {
    final s = v.toStringAsFixed(1).replaceAll('.', ',');
    return '$s КМ';
  }

  static String _fmtKmShort(double v) {
    return '${v.toStringAsFixed(1).replaceAll('.', ',')} км';
  }

  static String _fmtDiff(double percent) {
    final sign = percent < 0 ? '-' : '+';
    final pct = (percent.abs() * 100).toStringAsFixed(0);
    return '$sign$pct%';
  }

  @override
  Widget build(BuildContext context) {
    if (data.series.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Нет данных')),
      );
    }

    final online = data.series.firstWhere(
      (s) => s.id == 'online',
      orElse: () => data.series.first,
    );

    final mainValue = online.requested?.summary ?? 0.0;
    final diffPercent = online.summaryDiffPercent ?? 0.0;
    final isNegative = diffPercent < 0;

    // Sub-stats: trip_mileage / dead_mileage
    final useful = data.series.where((s) => s.id == 'trip_mileage').firstOrNull;
    final empty = data.series.where((s) => s.id == 'dead_mileage').firstOrNull;

    // Chart data
    final requested = online.requested?.values ?? [];
    final previous = online.previous?.values ?? [];

    double maxY = 0;
    for (final p in requested) {
      if (p.y > maxY) maxY = p.y;
    }
    for (final p in previous) {
      if (p.y > maxY) maxY = p.y;
    }
    if (maxY == 0) maxY = 10;
    // Pick a round interval so labels are 0, 20, 40, 60, 80 etc.
    final double niceInterval;
    if (maxY <= 5) niceInterval = 1;
    else if (maxY <= 10) niceInterval = 2;
    else if (maxY <= 20) niceInterval = 5;
    else if (maxY <= 50) niceInterval = 10;
    else niceInterval = 20;
    // Add 10% headroom so the top of data doesn't clip; the next nice label
    // (e.g. 100) will exceed maxYChart and therefore won't be rendered.
    final maxYChart = maxY * 1.1;

    final currentSpots = [
      for (int i = 0; i < requested.length; i++)
        FlSpot(i.toDouble(), requested[i].y),
    ];
    final previousSpots = [
      for (int i = 0; i < previous.length; i++)
        FlSpot(i.toDouble(), previous[i].y),
    ];

    final pointCount = requested.isNotEmpty ? requested.length : 30;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main stat
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _fmtKm(mainValue),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w400,
                height: 1,
                fontFamily: 'Yandex Sans Text',
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_fmtDiff(diffPercent)} ${isNegative ? '↓' : '↑'}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isNegative ? const Color(0xFFE63535) : const Color(0xFF21A64F),
                fontFamily: 'Yandex Sans Text',
              ),
            ),
          ],
        ),

        if (useful != null || empty != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              if (useful != null)
                _SubStatChip(
                  label: useful.name ?? 'Полезный пробег',
                  value: _fmtKmShort(useful.requested?.summary ?? 0),
                  diff: _fmtDiff(useful.summaryDiffPercent ?? 0),
                  isNegative: (useful.summaryDiffPercent ?? 0) < 0,
                ),
              if (useful != null && empty != null) const SizedBox(width: 8),
              if (empty != null)
                _SubStatChip(
                  label: empty.name ?? 'Холостой пробег',
                  value: _fmtKmShort(empty.requested?.summary ?? 0),
                  diff: _fmtDiff(empty.summaryDiffPercent ?? 0),
                  isNegative: (empty.summaryDiffPercent ?? 0) < 0,
                ),
            ],
          ),
        ],

        const SizedBox(height: 16),

        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (pointCount - 1).toDouble(),
              minY: 0,
              maxY: maxYChart,
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                verticalInterval: 5,
                horizontalInterval: niceInterval,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: Color(0xFFEEEEEE),
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (_) => const FlLine(
                  color: Color(0xFFEEEEEE),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 46,
                    interval: niceInterval,
                    getTitlesWidget: (value, meta) {
                      final v = value >= 1000
                          ? '${(value / 1000).toStringAsFixed(1)} тыс.'
                          : value.toInt().toString();
                      return Text(
                        '$v км',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF999999),
                          fontFamily: 'Yandex Sans Text',
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= requested.length) {
                        return const SizedBox.shrink();
                      }
                      final dateStr = requested[idx].x;
                      if (dateStr.length >= 10) {
                        final day = int.tryParse(dateStr.substring(8, 10)) ?? 0;
                        if (day % 5 != 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '$day',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF999999),
                              fontFamily: 'Yandex Sans Text',
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => Colors.white,
                  tooltipBorder: const BorderSide(color: Color(0xFFE0E0E0)),

                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spots) => spots.map((spot) {
                    final isPrev = previousSpots.isNotEmpty && spot.barIndex == 0;
                    final color = isPrev ? const Color(0xFFBBBBBB) : const Color(0xFFE63535);
                    final pts = isPrev ? previous : requested;
                    final idx = spot.x.toInt();
                    final date = idx >= 0 && idx < pts.length ? _fmtTooltipDate(pts[idx].x) : '';
                    final val = '${spot.y.toStringAsFixed(1).replaceAll('.', ',')} км';
                    return LineTooltipItem(
                      '● $val ',
                      TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Yandex Sans Text'),
                      children: [TextSpan(text: date, style: const TextStyle(color: Color(0xFF333333), fontSize: 12, fontWeight: FontWeight.normal, fontFamily: 'Yandex Sans Text'))],
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                if (previousSpots.isNotEmpty)
                  LineChartBarData(
                    spots: previousSpots,
                    isCurved: false,
                    color: const Color(0xFFBBBBBB),
                    barWidth: 1.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                LineChartBarData(
                  spots: currentSpots,
                  isCurved: false,
                  color: const Color(0xFFE63535),
                  barWidth: 1.5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SubStatChip extends StatelessWidget {
  final String label;
  final String value;
  final String diff;
  final bool isNegative;

  const _SubStatChip({
    required this.label,
    required this.value,
    required this.diff,
    required this.isNegative,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF888888),
              fontFamily: 'Yandex Sans Text',
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Yandex Sans Text',
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$diff ${isNegative ? '↓' : '↑'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isNegative ? const Color(0xFFE63535) : const Color(0xFF21A64F),
                  fontFamily: 'Yandex Sans Text',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Карточка "Часов на линии на ТС" ─────────────────────────────────────────

class _HoursOnlineCard extends ConsumerWidget {
  const _HoursOnlineCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(carsHoursOnlineProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Часов на линии на ТС',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Yandex Sans Text',
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.help_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ],
              ),
              FadingButton(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      'Отчёт',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Yandex Sans Text',
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          async.when(
            loading: () => const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  'Ошибка загрузки',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'Yandex Sans Text',
                  ),
                ),
              ),
            ),
            data: (data) => _HoursOnlineChartContent(data: data),
          ),
        ],
      ),
    );
  }
}

class _HoursOnlineChartContent extends StatelessWidget {
  final CarsMileageResponse data;

  const _HoursOnlineChartContent({required this.data});

  static String _fmtHours(double v) {
    final s = v.toStringAsFixed(1).replaceAll('.', ',');
    return '$s Ч';
  }

  static String _fmtDiff(double percent) {
    final sign = percent < 0 ? '-' : '+';
    final pct = (percent.abs() * 100).toStringAsFixed(0);
    return '$sign$pct%';
  }

  @override
  Widget build(BuildContext context) {
    if (data.series.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Нет данных')),
      );
    }

    final online = data.series.firstWhere(
      (s) => s.id == 'online',
      orElse: () => data.series.first,
    );

    final mainValue = online.requested?.summary ?? 0.0;
    final diffPercent = online.summaryDiffPercent ?? 0.0;
    final isNegative = diffPercent < 0;

    final requested = online.requested?.values ?? [];
    final previous = online.previous?.values ?? [];

    double maxY = 0;
    for (final p in requested) {
      if (p.y > maxY) maxY = p.y;
    }
    for (final p in previous) {
      if (p.y > maxY) maxY = p.y;
    }
    if (maxY == 0) maxY = 5;

    final double niceInterval;
    if (maxY <= 5) niceInterval = 1;
    else if (maxY <= 10) niceInterval = 2;
    else if (maxY <= 20) niceInterval = 5;
    else if (maxY <= 50) niceInterval = 10;
    else niceInterval = 20;
    // Ceiling to the nearest niceInterval so the top label aligns exactly
    final maxYChart = (maxY / niceInterval).ceil() * niceInterval;

    final currentSpots = [
      for (int i = 0; i < requested.length; i++)
        FlSpot(i.toDouble(), requested[i].y),
    ];
    final previousSpots = [
      for (int i = 0; i < previous.length; i++)
        FlSpot(i.toDouble(), previous[i].y),
    ];

    final pointCount = requested.isNotEmpty ? requested.length : 30;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _fmtHours(mainValue),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w400,
                height: 1,
                fontFamily: 'Yandex Sans Text',
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_fmtDiff(diffPercent)} ${isNegative ? '↓' : '↑'}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isNegative ? const Color(0xFFE63535) : const Color(0xFF21A64F),
                fontFamily: 'Yandex Sans Text',
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (pointCount - 1).toDouble(),
              minY: 0,
              maxY: maxYChart,
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                verticalInterval: 5,
                horizontalInterval: niceInterval,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: Color(0xFFEEEEEE),
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (_) => const FlLine(
                  color: Color(0xFFEEEEEE),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: niceInterval,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()} ч',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF999999),
                          fontFamily: 'Yandex Sans Text',
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= requested.length) {
                        return const SizedBox.shrink();
                      }
                      final dateStr = requested[idx].x;
                      if (dateStr.length >= 10) {
                        final day = int.tryParse(dateStr.substring(8, 10)) ?? 0;
                        if (day % 5 != 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '$day',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF999999),
                              fontFamily: 'Yandex Sans Text',
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => Colors.white,
                  tooltipBorder: const BorderSide(color: Color(0xFFE0E0E0)),

                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spots) => spots.map((spot) {
                    final isPrev = previousSpots.isNotEmpty && spot.barIndex == 0;
                    final color = isPrev ? const Color(0xFFBBBBBB) : const Color(0xFFE63535);
                    final pts = isPrev ? previous : requested;
                    final idx = spot.x.toInt();
                    final date = idx >= 0 && idx < pts.length ? _fmtTooltipDate(pts[idx].x) : '';
                    final val = '${spot.y.toStringAsFixed(1).replaceAll('.', ',')} ч';
                    return LineTooltipItem(
                      '● $val ',
                      TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Yandex Sans Text'),
                      children: [TextSpan(text: date, style: const TextStyle(color: Color(0xFF333333), fontSize: 12, fontWeight: FontWeight.normal, fontFamily: 'Yandex Sans Text'))],
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                if (previousSpots.isNotEmpty)
                  LineChartBarData(
                    spots: previousSpots,
                    isCurved: false,
                    color: const Color(0xFFBBBBBB),
                    barWidth: 1.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                LineChartBarData(
                  spots: currentSpots,
                  isCurved: false,
                  color: const Color(0xFFE63535),
                  barWidth: 1.5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Карточка "Доля принятых заказов" ────────────────────────────────────────

class _AcceptanceRateCard extends ConsumerWidget {
  const _AcceptanceRateCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(carsAcceptanceRateProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Доля принятых заказов',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Yandex Sans Text',
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.help_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ],
              ),
              FadingButton(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      'Отчёт',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Yandex Sans Text',
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          async.when(
            loading: () => const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  'Ошибка загрузки',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'Yandex Sans Text',
                  ),
                ),
              ),
            ),
            data: (data) => _AcceptanceRateChartContent(data: data),
          ),
        ],
      ),
    );
  }
}

class _AcceptanceRateChartContent extends StatelessWidget {
  final CarsMileageResponse data;

  const _AcceptanceRateChartContent({required this.data});

  static String _fmtDiff(double percent) {
    final sign = percent < 0 ? '-' : '+';
    final pct = (percent.abs() * 100).toStringAsFixed(0);
    return '$sign$pct%';
  }

  @override
  Widget build(BuildContext context) {
    if (data.series.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Нет данных')),
      );
    }

    final common = data.series.firstWhere(
      (s) => s.id == 'common',
      orElse: () => data.series.first,
    );

    final mainValue = common.requested?.summary ?? 0.0;
    final diffPercent = common.summaryDiffPercent ?? 0.0;
    final isNegative = diffPercent < 0;

    final requested = common.requested?.values ?? [];
    final previous = common.previous?.values ?? [];

    // API values are fractions 0–1; multiply by 100 for display
    final currentSpots = [
      for (int i = 0; i < requested.length; i++)
        FlSpot(i.toDouble(), requested[i].y * 100),
    ];
    final previousSpots = [
      for (int i = 0; i < previous.length; i++)
        FlSpot(i.toDouble(), previous[i].y * 100),
    ];

    final pointCount = requested.isNotEmpty ? requested.length : 30;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${(mainValue * 100).toStringAsFixed(0)} %',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w400,
                height: 1,
                fontFamily: 'Yandex Sans Text',
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_fmtDiff(diffPercent)} ${isNegative ? '↓' : '↑'}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isNegative ? const Color(0xFFE63535) : const Color(0xFF21A64F),
                fontFamily: 'Yandex Sans Text',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (pointCount - 1).toDouble(),
              minY: 0,
              maxY: 100,
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                verticalInterval: 5,
                horizontalInterval: 50,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: Color(0xFFEEEEEE),
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (_) => const FlLine(
                  color: Color(0xFFEEEEEE),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    interval: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()} %',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF999999),
                          fontFamily: 'Yandex Sans Text',
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= requested.length) {
                        return const SizedBox.shrink();
                      }
                      final dateStr = requested[idx].x;
                      if (dateStr.length >= 10) {
                        final day = int.tryParse(dateStr.substring(8, 10)) ?? 0;
                        if (day % 5 != 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '$day',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF999999),
                              fontFamily: 'Yandex Sans Text',
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => Colors.white,
                  tooltipBorder: const BorderSide(color: Color(0xFFE0E0E0)),

                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spots) => spots.map((spot) {
                    final isPrev = previousSpots.isNotEmpty && spot.barIndex == 0;
                    final color = isPrev ? const Color(0xFFBBBBBB) : const Color(0xFFE63535);
                    final pts = isPrev ? previous : requested;
                    final idx = spot.x.toInt();
                    final date = idx >= 0 && idx < pts.length ? _fmtTooltipDate(pts[idx].x) : '';
                    final val = '${spot.y.toStringAsFixed(0)} %';
                    return LineTooltipItem(
                      '● $val ',
                      TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Yandex Sans Text'),
                      children: [TextSpan(text: date, style: const TextStyle(color: Color(0xFF333333), fontSize: 12, fontWeight: FontWeight.normal, fontFamily: 'Yandex Sans Text'))],
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                if (previousSpots.isNotEmpty)
                  LineChartBarData(
                    spots: previousSpots,
                    isCurved: false,
                    color: const Color(0xFFBBBBBB),
                    barWidth: 1.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                LineChartBarData(
                  spots: currentSpots,
                  isCurved: false,
                  color: const Color(0xFFE63535),
                  barWidth: 1.5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Карточка "Поездки на ТС на линии" ───────────────────────────────────────

class _TripsCard extends ConsumerWidget {
  const _TripsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(carsTripsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Поездки на ТС на линии',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Yandex Sans Text',
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.help_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ],
              ),
              FadingButton(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      'Отчёт',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Yandex Sans Text',
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          async.when(
            loading: () => const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  'Ошибка загрузки',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'Yandex Sans Text',
                  ),
                ),
              ),
            ),
            data: (data) => _TripsChartContent(data: data),
          ),
        ],
      ),
    );
  }
}

class _TripsChartContent extends StatelessWidget {
  final CarsMileageResponse data;

  const _TripsChartContent({required this.data});

  static String _fmtDiff(double percent) {
    final sign = percent < 0 ? '-' : '+';
    final pct = (percent.abs() * 100).toStringAsFixed(0);
    return '$sign$pct%';
  }

  @override
  Widget build(BuildContext context) {
    if (data.series.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Нет данных')),
      );
    }

    final online = data.series.firstWhere(
      (s) => s.id == 'online',
      orElse: () => data.series.first,
    );

    final mainValue = online.requested?.summary ?? 0.0;
    final diffPercent = online.summaryDiffPercent ?? 0.0;
    final isNegative = diffPercent < 0;

    final requested = online.requested?.values ?? [];
    final previous = online.previous?.values ?? [];

    double maxY = 0;
    for (final p in [...requested, ...previous]) {
      if (p.y > maxY) maxY = p.y;
    }
    if (maxY == 0) maxY = 4;

    final double niceInterval;
    if (maxY <= 5) niceInterval = 1;
    else if (maxY <= 10) niceInterval = 2;
    else if (maxY <= 20) niceInterval = 5;
    else if (maxY <= 50) niceInterval = 10;
    else niceInterval = 20;
    final maxYChart = (maxY / niceInterval).ceil() * niceInterval;

    final currentSpots = [
      for (int i = 0; i < requested.length; i++)
        FlSpot(i.toDouble(), requested[i].y),
    ];
    final previousSpots = [
      for (int i = 0; i < previous.length; i++)
        FlSpot(i.toDouble(), previous[i].y),
    ];

    final pointCount = requested.isNotEmpty ? requested.length : 30;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              mainValue.toStringAsFixed(1).replaceAll('.', ','),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w400,
                height: 1,
                fontFamily: 'Yandex Sans Text',
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_fmtDiff(diffPercent)} ${isNegative ? '↓' : '↑'}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isNegative ? const Color(0xFFE63535) : const Color(0xFF21A64F),
                fontFamily: 'Yandex Sans Text',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (pointCount - 1).toDouble(),
              minY: 0,
              maxY: maxYChart.toDouble(),
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                verticalInterval: 5,
                horizontalInterval: niceInterval,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: Color(0xFFEEEEEE),
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (_) => const FlLine(
                  color: Color(0xFFEEEEEE),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: niceInterval,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF999999),
                          fontFamily: 'Yandex Sans Text',
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= requested.length) {
                        return const SizedBox.shrink();
                      }
                      final dateStr = requested[idx].x;
                      if (dateStr.length >= 10) {
                        final day = int.tryParse(dateStr.substring(8, 10)) ?? 0;
                        if (day % 5 != 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '$day',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF999999),
                              fontFamily: 'Yandex Sans Text',
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => Colors.white,
                  tooltipBorder: const BorderSide(color: Color(0xFFE0E0E0)),
                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spots) => spots.map((spot) {
                    final isPrev = previousSpots.isNotEmpty && spot.barIndex == 0;
                    final color = isPrev ? const Color(0xFFBBBBBB) : const Color(0xFFE63535);
                    final pts = isPrev ? previous : requested;
                    final idx = spot.x.toInt();
                    final date = idx >= 0 && idx < pts.length ? _fmtTooltipDate(pts[idx].x) : '';
                    final val = spot.y.toStringAsFixed(1).replaceAll('.', ',');
                    return LineTooltipItem(
                      '● $val ',
                      TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Yandex Sans Text'),
                      children: [TextSpan(text: date, style: const TextStyle(color: Color(0xFF333333), fontSize: 12, fontWeight: FontWeight.normal, fontFamily: 'Yandex Sans Text'))],
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                if (previousSpots.isNotEmpty)
                  LineChartBarData(
                    spots: previousSpots,
                    isCurved: false,
                    color: const Color(0xFFBBBBBB),
                    barWidth: 1.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                LineChartBarData(
                  spots: currentSpots,
                  isCurved: false,
                  color: const Color(0xFFE63535),
                  barWidth: 1.5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
