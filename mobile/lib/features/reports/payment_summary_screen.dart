import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/reports/domain/payment_dashboard.dart';
import 'package:mobile/features/reports/providers/payment_dashboard_provider.dart';
import 'package:mobile/shared/widgets/custom_date_range_picker_bottom_sheet.dart';
import 'package:mobile/shared/widgets/filter_chip.dart';
import 'package:mobile/shared/widgets/pulse_box.dart';

class PaymentSummaryScreen extends ConsumerWidget {
  const PaymentSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentDashboardProvider);
    final notifier = ref.read(paymentDashboardProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Расчёты с исполнителями'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // Tab + date toolbar
          _Toolbar(
            isTopup: state.isTopup,
            dateFrom: state.dateFrom,
            dateTo: state.dateTo,
            onTabChanged: notifier.setTab,
            onDateChanged: notifier.setDateRange,
          ),

          // Body
          Expanded(
            child: RefreshIndicator(
              onRefresh: notifier.refresh,
              child: state.error != null && state.data == null
                  ? _ErrorBody(
                      error: state.error!, onRetry: notifier.refresh)
                  : _DashboardBody(
                      state: state,
                      isTopup: state.isTopup,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Toolbar

class _Toolbar extends StatelessWidget {
  final bool isTopup;
  final DateTime dateFrom;
  final DateTime dateTo;
  final ValueChanged<bool> onTabChanged;
  final void Function(DateTime, DateTime) onDateChanged;

  const _Toolbar({
    required this.isTopup,
    required this.dateFrom,
    required this.dateTo,
    required this.onTabChanged,
    required this.onDateChanged,
  });

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          // Tab chips
          CustomFilterChip(
            label: 'Выплаты',
            isSelected: !isTopup,
            onTap: () => onTabChanged(false),
            borderRadius: 20,
          ),
          const SizedBox(width: 8),
          CustomFilterChip(
            label: 'Пополнения',
            isSelected: isTopup,
            onTap: () => onTabChanged(true),
            borderRadius: 20,
          ),
          const Spacer(),
          // Date picker chip
          GestureDetector(
            onTap: () async {
              final range = await CustomDateRangePickerBottomSheet.show(
                context: context,
                title: 'Выберите период',
                startDate: dateFrom,
                endDate: dateTo,
              );
              if (range != null) {
                onDateChanged(range.start, range.end);
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E5EA)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 13, color: AppTheme.textSecondary),
                  const SizedBox(width: 5),
                  Text(
                    '${_fmt(dateFrom)} – ${_fmt(dateTo)}',
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Dashboard body

class _DashboardBody extends StatelessWidget {
  final PaymentDashboardState state;
  final bool isTopup;

  const _DashboardBody({required this.state, required this.isTopup});

  @override
  Widget build(BuildContext context) {
    final isLoading = state.isLoading && state.data == null;
    final d = state.data;

    final driversData = isTopup ? d?.transactionsDrivers.topupWidget : d?.transactionsDrivers.payoutWidget;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        _ChartCard(
          title: 'Оборот',
          isLoading: isLoading,
          series: d?.transactionsSummary.total,
          isMoney: true,
        ),
        if (!isTopup) ...[
          const SizedBox(height: 12),
          _ChartCard(
            title: 'Доход партнёра',
            isLoading: isLoading,
            series: d?.feesSummary.total,
            isMoney: true,
          ),
        ],
        const SizedBox(height: 12),
        _ChartCard(
          title: 'Исполнители с транзакциями',
          isLoading: isLoading,
          series: driversData?.total,
          isMoney: false,
        ),
        const SizedBox(height: 12),
        _ChartCard(
          title: 'Завершённые транзакции',
          isLoading: isLoading,
          series: d?.transactionsCount.total,
          isMoney: false,
        ),
        if (!isTopup) ...[
          const SizedBox(height: 12),
          _StatusCard(
            isLoading: isLoading,
            data: d?.transactionsStatuses,
          ),
        ],
      ],
    );
  }
}

// Chart card

class _ChartCard extends StatelessWidget {
  final String title;
  final bool isLoading;
  final DashboardSeries? series;
  final bool isMoney;

  const _ChartCard({
    required this.title,
    required this.isLoading,
    required this.series,
    required this.isMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              fontFamily: 'Yandex Sans Text',
            ),
          ),
          const SizedBox(height: 10),
          if (isLoading)
            const _CardSkeleton()
          else if (series == null)
            const SizedBox(height: 120, child: Center(child: Text('—')))
          else
            _ChartContent(series: series!, isMoney: isMoney),
        ],
      ),
    );
  }
}

class _ChartContent extends StatelessWidget {
  final DashboardSeries series;
  final bool isMoney;

  const _ChartContent({required this.series, required this.isMoney});

  static String _fmtValue(double v, bool isMoney) {
    if (isMoney) {
      final s = v.toStringAsFixed(2).replaceAll('.', ',');
      final parts = s.split(',');
      final integer = parts[0];
      final grouped = _groupDigits(integer);
      return '$grouped,${parts[1]} ₽';
    }
    return v.toInt().toString();
  }

  static String _groupDigits(String s) {
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static double _niceInterval(double maxY, {int ticks = 4}) {
    if (maxY <= 0) return 1;
    final raw = maxY / ticks;
    double mag = 1;
    if (raw >= 1) {
      while (mag * 10 <= raw) mag *= 10;
    } else {
      while (mag > raw) mag /= 10;
    }
    if (raw <= 1 * mag) return 1 * mag;
    if (raw <= 2 * mag) return 2 * mag;
    if (raw <= 5 * mag) return 5 * mag;
    return 10 * mag;
  }

  @override
  Widget build(BuildContext context) {
    final req = series.requested;
    final value = req.summary.value;
    final diff = req.summary.diffValue;

    final spots = <FlSpot>[];
    for (int i = 0; i < req.values.length; i++) {
      spots.add(FlSpot(i.toDouble(), req.values[i].y));
    }

    final prevSpots = <FlSpot>[];
    for (int i = 0; i < series.previous.values.length; i++) {
      prevSpots.add(FlSpot(i.toDouble(), series.previous.values[i].y));
    }

    double maxY = 0;
    for (final p in req.values) {
      if (p.y > maxY) maxY = p.y;
    }
    for (final p in series.previous.values) {
      if (p.y > maxY) maxY = p.y;
    }
    if (maxY == 0) maxY = 1;
    final interval = _niceInterval(maxY);
    final maxYChart = interval * (maxY / interval).ceil() + interval;

    final labels = req.values.map((p) => p.weekdayLabel).toList();

    final isNegativeDiff = diff != null && diff < 0;
    final diffColor = isNegativeDiff
        ? const Color(0xFFE64646)
        : const Color(0xFF00B341);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Value + diff
        Text(
          _fmtValue(value, isMoney),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            height: 1,
            fontFamily: 'Yandex Sans Text',
          ),
        ),
        if (diff != null && diff != 0) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${isNegativeDiff ? '' : '+'}${(diff * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: diffColor,
                  fontFamily: 'Yandex Sans Text',
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                isNegativeDiff ? Icons.arrow_downward : Icons.arrow_upward,
                size: 13,
                color: diffColor,
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        // Chart
        SizedBox(
          height: 120,
          child: spots.isEmpty
              ? const Center(child: Text('—'))
              : LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (spots.length - 1).toDouble(),
                    minY: 0,
                    maxY: maxYChart,
                    clipData: const FlClipData.all(),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: interval,
                      verticalInterval: spots.length <= 7 ? 1
                          : spots.length <= 14 ? 2
                          : spots.length <= 31 ? 7
                          : 10,
                      getDrawingHorizontalLine: (_) => const FlLine(
                          color: Color(0xFFF0F0F0), strokeWidth: 1),
                      getDrawingVerticalLine: (_) => const FlLine(
                          color: Color(0xFFF0F0F0), strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          interval: interval,
                          getTitlesWidget: (v, _) {
                            if (v > maxYChart) return const SizedBox.shrink();
                            final label = v >= 1000
                                ? '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}к'
                                : v.toInt().toString();
                            return Text(label,
                                style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF999999),
                                    fontFamily: 'Yandex Sans Text'));
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 20,
                          interval: 1,
                          getTitlesWidget: (v, _) {
                            final idx = v.toInt();
                            if (idx < 0 || idx >= labels.length) {
                              return const SizedBox.shrink();
                            }
                            // For many points show only every Nth label
                            final n = spots.length;
                            final step = n <= 7 ? 1
                                : n <= 14 ? 2
                                : n <= 31 ? 7
                                : 10;
                            if (idx % step != 0) return const SizedBox.shrink();

                            final lbl = labels[idx];
                            // Long period: show only day number; short period: weekday abbr
                            final display = n > 7
                                ? lbl.split(' ').lastOrNull ?? lbl
                                : lbl.split(' ').firstOrNull ?? lbl;

                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                display,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF999999),
                                  fontFamily: 'Yandex Sans Text',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: const Border(
                        bottom: BorderSide(
                            color: Color(0xFFEEEEEE), width: 1),
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => Colors.white,
                        tooltipBorder:
                            const BorderSide(color: Color(0xFFE0E0E0)),
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        getTooltipItems: (touchedSpots) =>
                            touchedSpots.map((spot) {
                          final idx = spot.x.toInt();
                          final lbl = idx >= 0 && idx < labels.length
                              ? labels[idx]
                              : '';
                          return LineTooltipItem(
                            '${_fmtValue(spot.y, isMoney)}\n',
                            const TextStyle(
                                color: Color(0xFF00B341),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Yandex Sans Text'),
                            children: [
                              TextSpan(
                                text: lbl,
                                style: const TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 11,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Yandex Sans Text'),
                              )
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    lineBarsData: [
                      if (prevSpots.isNotEmpty)
                        LineChartBarData(
                          spots: prevSpots,
                          isCurved: false,
                          color: const Color(0xFFCCCCCC),
                          barWidth: 1.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      LineChartBarData(
                        spots: spots,
                        isCurved: false,
                        color: isNegativeDiff
                            ? const Color(0xFFE64646)
                            : const Color(0xFF00B341),
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

// Status card

class _StatusCard extends StatelessWidget {
  final bool isLoading;
  final TransactionStatusesResponse? data;

  const _StatusCard({required this.isLoading, required this.data});

  static const _statusColors = {
    'completed': Color(0xFF00B341),
    'error': Color(0xFFE64646),
    'INSUFFICIENT_FUNDS': Color(0xFFE64646),
    'pending': Color(0xFFFFB300),
    'processing': Color(0xFF2979FF),
  };

  static Color _colorFor(String status) =>
      _statusColors[status] ?? const Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Транзакции',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              fontFamily: 'Yandex Sans Text',
            ),
          ),
          const SizedBox(height: 10),
          if (isLoading)
            const _StatusSkeleton()
          else if (data == null)
            const SizedBox(height: 60, child: Center(child: Text('—')))
          else ...[
            Text(
              data!.total.toInt().toString(),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w400,
                height: 1,
                fontFamily: 'Yandex Sans Text',
              ),
            ),
            const SizedBox(height: 14),
            ...data!.statuses.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _colorFor(s.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.statusText,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                            fontFamily: 'Yandex Sans Text',
                          ),
                        ),
                      ),
                      Text(
                        '${(s.value * 100).toStringAsFixed(0)} %',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          fontFamily: 'Yandex Sans Text',
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

// Skeletons

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        PulseBox(width: 90, height: 26, borderRadius: 6),
        SizedBox(height: 8),
        PulseBox(width: 60, height: 14, borderRadius: 4),
        SizedBox(height: 14),
        PulseBox(height: 120, borderRadius: 8),
      ],
    );
  }
}

class _StatusSkeleton extends StatelessWidget {
  const _StatusSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PulseBox(width: 50, height: 36, borderRadius: 6),
        const SizedBox(height: 14),
        for (int i = 0; i < 2; i++) ...[
          const PulseBox(height: 14, borderRadius: 6),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

// Error body

class _ErrorBody extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorBody({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppTheme.textSecondary),
            const SizedBox(height: 12),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}
