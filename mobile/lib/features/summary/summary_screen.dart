import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/summary/providers/summary_provider.dart';
import 'package:mobile/features/summary/models/active_drivers_model.dart';
import 'package:mobile/shared/widgets/pulse_box.dart';
import 'package:mobile/shared/widgets/custom_date_range_picker_bottom_sheet.dart';

const _mos = ['янв.','фев.','мар.','апр.','мая','июн.','июл.','авг.','сен.','окт.','ноя.','дек.'];
String _pLabel(DateRange d) => d.start.month == d.end.month
    ? '${d.start.day}–${d.end.day} ${_mos[d.start.month-1]}'
    : '${d.start.day} ${_mos[d.start.month-1]} – ${d.end.day} ${_mos[d.end.month-1]}';
String _fN(double v) { if(v.abs()>=1e6) return '${(v/1e6).toStringAsFixed(1)} млн.'; if(v.abs()>=1000) return '${(v/1000).round()} тыс.'; return v.toInt().toString(); }
String _fM(double v) => '${_fN(v)} \u20BD';
String _fH(double s) => '${(s/3600).round()} ч';
String _fD(double d) { final p=(d*100).round(); return '${p>=0?"+":""}$p %'; }
Color _dC(double? d) => d!=null&&d<0 ? const Color(0xFFE64646) : const Color(0xFF00B341);
const _cc = [Color(0xFF00B341),Color(0xFFFF3B30),Color(0xFFFF9500),Color(0xFFAF52DE),Color(0xFF007AFF),Color(0xFF8E8E93),Color(0xFF5856D6),Color(0xFFFF2D55)];

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Сводка'), centerTitle: true, scrolledUnderElevation: 0),
      body: SafeArea(child: RefreshIndicator(
        onRefresh: () async { for (final p in [activeDriversProvider,ordersByTariffProvider,ordersByStatusProvider,ordersByPaymentProvider,supplyHoursProvider,profitProvider,ordersSumProvider,certificationProvider]) ref.invalidate(p); },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: const [
            _PeriodBtn(), SizedBox(height:12), _ProfileCard(), SizedBox(height:12),
            _ActiveCard(), SizedBox(height:12), _TariffsCard(), SizedBox(height:12),
            _HoursCard(), SizedBox(height:12), _ProfitCard(), SizedBox(height:12),
            _SumCard(), SizedBox(height:12), _OrdersCard(), SizedBox(height:12),
            _PayCard(), SizedBox(height:12), _CertCard(), SizedBox(height:24),
          ]),
        ),
      )),
    );
  }
}

class _PeriodBtn extends ConsumerWidget {
  const _PeriodBtn();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dr = ref.watch(summaryDateRangeProvider);
    return GestureDetector(
      onTap: () async {
        final r = await CustomDateRangePickerBottomSheet.show(context: context, title: 'Период', startDate: dr.start, endDate: dr.end);
        if (r != null) ref.read(summaryDateRangeProvider.notifier).update(r);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.textPrimary),
          const SizedBox(width: 8),
          Text('Период: ${_pLabel(dr)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Yandex Sans Text')),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 18, color: AppTheme.textSecondary),
        ]),
      ),
    );
  }
}

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(parkProfileProvider).when(
      data: (d) {
        final p = d.park; final s = p.timezoneOffset>=0?'+':'-'; final o = p.timezoneOffset.abs().toString().padLeft(2,'0');
        return Container(
          decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w500, fontFamily: 'Yandex Sans Text', letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Row(children: [
              Text('Clid ${p.clid}', style: const TextStyle(fontSize: 18, fontFamily: 'Yandex Sans Text')),
              const SizedBox(width: 8),
              GestureDetector(onTap: () { Clipboard.setData(ClipboardData(text: p.clid)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clid скопирован'))); },
                child: const Icon(Icons.copy_outlined, size: 20)),
            ]),
            const SizedBox(height: 48),
            Text('${p.city.name}, $s$o:00, Данные отображаются\nс задержкой до 1 часа', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontFamily: 'Yandex Sans Text', height: 1.3)),
          ]),
        );
      },
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
      error: (e, _) => Padding(padding: const EdgeInsets.all(32), child: Text('$e')),
    );
  }
}

// ─── Shared helpers ──────────────────────────────────────────────────────────

Widget _loading() => Container(
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5)),
  padding: const EdgeInsets.all(14),
  child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    PulseBox(width: 130, height: 13, borderRadius: 4), SizedBox(height: 10),
    PulseBox(width: 70, height: 24, borderRadius: 6), SizedBox(height: 14),
    PulseBox(height: 120, borderRadius: 8),
  ]),
);
Widget _err(Object e) => Container(
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5)),
  padding: const EdgeInsets.all(14), child: Text('$e', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
);

class _Card extends StatelessWidget {
  final String title; final Widget child;
  const _Card({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5)),
    padding: const EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, fontFamily: 'Yandex Sans Text')),
      const SizedBox(height: 8), child,
    ]),
  );
}

class _Big extends StatelessWidget {
  final String value; final double? diff;
  const _Big({required this.value, this.diff});
  @override
  Widget build(BuildContext context) {
    final neg = diff != null && diff! < 0;
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w400, height: 1, fontFamily: 'Yandex Sans Text')),
      if (diff != null && diff != 0) ...[
        const SizedBox(width: 8),
        Padding(padding: const EdgeInsets.only(bottom: 2), child: Text('${_fD(diff!)} ${neg?"↓":"↑"}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _dC(diff), fontFamily: 'Yandex Sans Text'))),
      ],
    ]);
  }
}

class _Badges extends StatelessWidget {
  final List<ActiveDriversSeries> items; final String Function(double) fmt;
  const _Badges({required this.items, required this.fmt});
  @override
  Widget build(BuildContext context) => Wrap(spacing: 8, runSpacing: 6, children: items.map((s) {
    final v = s.requested?.summary ?? 0; final d = s.summaryDiffPercent; final neg = d != null && d < 0;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF5F4F2), borderRadius: BorderRadius.circular(8)),
      child: Text.rich(TextSpan(children: [
        TextSpan(text: '${s.name ?? s.id}\n', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontFamily: 'Yandex Sans Text')),
        TextSpan(text: fmt(v), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Yandex Sans Text')),
        if (d != null && d != 0) TextSpan(text: ' ${_fD(d)} ${neg?"↓":"↑"}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _dC(d), fontFamily: 'Yandex Sans Text')),
      ])),
    );
  }).toList());
}

class _Legend extends StatelessWidget {
  final List<MapEntry<String, Color>> items;
  const _Legend({required this.items});
  @override
  Widget build(BuildContext context) => Wrap(spacing: 12, runSpacing: 4, children: items.map((e) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: e.value, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text(e.key, style: const TextStyle(fontSize: 11, fontFamily: 'Yandex Sans Text', color: AppTheme.textSecondary)),
  ])).toList());
}

// ─── Chart builders ──────────────────────────────────────────────────────────

double _ni(double m, {int t = 4}) {
  if (m <= 0) return 1; final r = m / t; double g = 1;
  if (r >= 1) { while (g * 10 <= r) g *= 10; } else { while (g > r) g /= 10; }
  if (r <= g) return g; if (r <= 2*g) return 2*g; if (r <= 5*g) return 5*g; return 10*g;
}

int _step(int n) => n <= 7 ? 1 : n <= 14 ? 2 : n <= 31 ? 7 : 10;

List<String> _lb(ActiveDriversSeries s) {
  final vals = s.requested?.values ?? [];
  if (vals.length > 7) {
    return vals.map((p) {
      try { final dt = DateTime.parse(p.x); return '${dt.day}.${dt.month.toString().padLeft(2,"0")}'; } catch (_) { return ''; }
    }).toList();
  }
  return vals.map((p) => p.weekdayLabel).toList();
}
ActiveDriversSeries? _cm(ActiveDriversResponse d) { final l = d.series.where((s) => s.id == 'common'); return l.isEmpty ? null : l.first; }
List<ActiveDriversSeries> _nc(ActiveDriversResponse d) => d.series.where((s) => s.id != 'common').toList();

FlTitlesData _titles(List<String> labels, double interval, double maxYC, {String Function(double)? yFmt}) => FlTitlesData(
  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36, interval: interval,
    getTitlesWidget: (v, _) => v > maxYC ? const SizedBox.shrink() : Text(yFmt != null ? yFmt(v) : v.toInt().toString(), style: const TextStyle(fontSize: 9, color: Color(0xFF999999), fontFamily: 'Yandex Sans Text')))),
  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 20, interval: 1,
    getTitlesWidget: (v, _) { final i = v.toInt(); final st = _step(labels.length); return (i < 0 || i >= labels.length || i % st != 0) ? const SizedBox.shrink() : Padding(padding: const EdgeInsets.only(top: 4), child: Text(labels[i], style: const TextStyle(fontSize: 9, color: Color(0xFF999999), fontFamily: 'Yandex Sans Text'))); })),
);

Widget _lineChart({required List<FlSpot> spots, List<FlSpot>? prev, required List<String> labels, Color color = const Color(0xFF00B341), String Function(double)? yFmt}) {
  if (spots.isEmpty) return const SizedBox(height: 130, child: Center(child: Text('—')));
  double mx = 0; for (final p in spots) { if (p.y > mx) mx = p.y; }
  if (prev != null) for (final p in prev) { if (p.y > mx) mx = p.y; }
  if (mx == 0) mx = 1;
  final iv = _ni(mx); final mc = iv * (mx / iv).ceil() + iv;
  return SizedBox(height: 130, child: LineChart(LineChartData(
    minX: 0, maxX: (spots.length - 1).toDouble(), minY: 0, maxY: mc, clipData: const FlClipData.all(),
    gridData: FlGridData(show: true, drawVerticalLine: true, horizontalInterval: iv, verticalInterval: _step(spots.length).toDouble(),
      getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFF0F0F0), strokeWidth: 1),
      getDrawingVerticalLine: (_) => const FlLine(color: Color(0xFFF0F0F0), strokeWidth: 1)),
    titlesData: _titles(labels, iv, mc, yFmt: yFmt),
    borderData: FlBorderData(show: true, border: const Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1))),
    lineTouchData: LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => Colors.white,
        tooltipBorder: const BorderSide(color: Color(0xFFE0E0E0)),
        fitInsideHorizontally: true, fitInsideVertically: true,
        getTooltipItems: (touched) => touched.map((spot) {
          final idx = spot.x.toInt();
          final lbl = idx >= 0 && idx < labels.length ? labels[idx] : '';
          final val = yFmt != null ? yFmt(spot.y) : spot.y.toInt().toString();
          return LineTooltipItem('$val\n', TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Yandex Sans Text'),
            children: [TextSpan(text: lbl, style: const TextStyle(color: Color(0xFF666666), fontSize: 11, fontWeight: FontWeight.normal, fontFamily: 'Yandex Sans Text'))]);
        }).toList(),
      ),
    ),
    lineBarsData: [
      if (prev != null && prev.isNotEmpty) LineChartBarData(spots: prev, isCurved: false, color: const Color(0xFFCCCCCC), barWidth: 1.5, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: false), dashArray: [4, 4]),
      LineChartBarData(spots: spots, isCurved: false, color: color, barWidth: 2, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: false)),
    ],
  )));
}

Widget _multiLine({required List<ActiveDriversSeries> series, required List<String> labels, required List<Color> colors}) {
  if (series.isEmpty) return const SizedBox(height: 130, child: Center(child: Text('—')));
  double mx = 0; final lines = <LineChartBarData>[];
  for (int si = 0; si < series.length; si++) {
    final s = series[si]; if (s.requested == null || s.requested!.values.isEmpty) continue;
    final sp = <FlSpot>[]; for (int i = 0; i < s.requested!.values.length; i++) { final y = s.requested!.values[i].y; if (y > mx) mx = y; sp.add(FlSpot(i.toDouble(), y)); }
    lines.add(LineChartBarData(spots: sp, isCurved: false, color: colors[si % colors.length], barWidth: 2, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: false)));
    if (s.previous != null && s.previous!.values.isNotEmpty) {
      final pv = <FlSpot>[]; for (int i = 0; i < s.previous!.values.length; i++) { final y = s.previous!.values[i].y; if (y > mx) mx = y; pv.add(FlSpot(i.toDouble(), y)); }
      lines.add(LineChartBarData(spots: pv, isCurved: false, color: colors[si % colors.length].withOpacity(0.3), barWidth: 1, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: false), dashArray: [4, 4]));
    }
  }
  if (mx == 0) mx = 1; final iv = _ni(mx); final mc = iv * (mx / iv).ceil() + iv;
  final n = series.first.requested!.values.length;
  return SizedBox(height: 130, child: LineChart(LineChartData(
    minX: 0, maxX: (n - 1).toDouble(), minY: 0, maxY: mc, clipData: const FlClipData.all(),
    gridData: FlGridData(show: true, drawVerticalLine: true, horizontalInterval: iv, verticalInterval: _step(n).toDouble(),
      getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFF0F0F0), strokeWidth: 1),
      getDrawingVerticalLine: (_) => const FlLine(color: Color(0xFFF0F0F0), strokeWidth: 1)),
    titlesData: _titles(labels, iv, mc),
    borderData: FlBorderData(show: true, border: const Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1))),
    lineTouchData: LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => Colors.white,
        tooltipBorder: const BorderSide(color: Color(0xFFE0E0E0)),
        fitInsideHorizontally: true, fitInsideVertically: true,
        getTooltipItems: (touched) => touched.map((spot) {
          final idx = spot.x.toInt();
          final lbl = idx >= 0 && idx < labels.length ? labels[idx] : '';
          return LineTooltipItem('${spot.y.toInt()}\n', TextStyle(color: spot.bar.color ?? Colors.green, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Yandex Sans Text'),
            children: [TextSpan(text: lbl, style: const TextStyle(color: Color(0xFF666666), fontSize: 11, fontWeight: FontWeight.normal, fontFamily: 'Yandex Sans Text'))]);
        }).toList(),
      ),
    ),
    lineBarsData: lines,
  )));
}

Widget _stackBar({required List<ActiveDriversSeries> series, required List<String> labels}) {
  const bc = [Color(0xFF00B341), Color(0xFFE64646), Color(0xFFFF9500)];
  final n = series.isNotEmpty && series.first.requested != null ? series.first.requested!.values.length : 0;
  if (n == 0) return const SizedBox(height: 130, child: Center(child: Text('—')));
  double mx = 0; final groups = <BarChartGroupData>[];
  for (int i = 0; i < n; i++) {
    double cum = 0; final st = <BarChartRodStackItem>[];
    for (int si = 0; si < series.length; si++) {
      final s = series[si]; if (s.requested == null || i >= s.requested!.values.length) continue;
      final y = s.requested!.values[i].y; st.add(BarChartRodStackItem(cum, cum + y, bc[si % bc.length])); cum += y;
    }
    if (cum > mx) mx = cum;
    groups.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: cum, width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(3)), rodStackItems: st, color: Colors.transparent)]));
  }
  if (mx == 0) mx = 1; final iv = _ni(mx); final mc = iv * (mx / iv).ceil() + iv;
  return SizedBox(height: 130, child: BarChart(BarChartData(
    maxY: mc, barGroups: groups,
    gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: iv, verticalInterval: _step(n).toDouble(), getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFF0F0F0), strokeWidth: 1)),
    titlesData: _titles(labels, iv, mc),
    borderData: FlBorderData(show: true, border: const Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1))),
    barTouchData: BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) => Colors.white,
        tooltipBorder: const BorderSide(color: Color(0xFFE0E0E0)),
        fitInsideHorizontally: true, fitInsideVertically: true,
        getTooltipItem: (group, gIdx, rod, rIdx) {
          final idx = group.x; final lbl = idx >= 0 && idx < labels.length ? labels[idx] : '';
          final lines = <TextSpan>[]; for (final st in rod.rodStackItems) {
            lines.add(TextSpan(text: '${(st.toY - st.fromY).toInt()} ', style: TextStyle(color: st.color, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Yandex Sans Text')));
          }
          lines.add(TextSpan(text: '\n$lbl', style: const TextStyle(color: Color(0xFF666666), fontSize: 11, fontWeight: FontWeight.normal, fontFamily: 'Yandex Sans Text')));
          return BarTooltipItem('', const TextStyle(), children: lines);
        },
      ),
    ),
  )));
}

List<FlSpot> _spots(ActiveDriversSeries s, {double div = 1}) => s.requested!.values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.y / div)).toList();
List<FlSpot>? _prev(ActiveDriversSeries s, {double div = 1}) => s.previous?.values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.y / div)).toList();

// ─── Dashboard cards ─────────────────────────────────────────────────────────

class _ActiveCard extends ConsumerWidget {
  const _ActiveCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref.watch(activeDriversProvider).when(loading: () => _loading(), error: (e, _) => _err(e), data: (data) {
    final c = _cm(data); if (c?.requested == null) return const SizedBox.shrink();
    return _Card(title: 'Активность', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Big(value: (c!.requested!.summary ?? 0).toInt().toString(), diff: c.summaryDiffPercent),
      if (_nc(data).isNotEmpty) ...[const SizedBox(height: 8), _Badges(items: _nc(data), fmt: (v) => v.toInt().toString())],
      const SizedBox(height: 12), _lineChart(spots: _spots(c), prev: _prev(c), labels: _lb(c)),
    ]));
  });
}

class _TariffsCard extends ConsumerWidget {
  const _TariffsCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref.watch(ordersByTariffProvider).when(loading: () => _loading(), error: (e, _) => _err(e), data: (data) {
    final nc = _nc(data).where((s) => s.requested != null && s.requested!.values.isNotEmpty).toList();
    if (nc.isEmpty) return const SizedBox.shrink();
    final legend = nc.asMap().entries.map((e) => MapEntry(e.value.name ?? e.value.id, _cc[e.key % _cc.length])).toList();
    return _Card(title: 'Тарифы', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Legend(items: legend), const SizedBox(height: 12), _multiLine(series: nc, labels: _lb(nc.first), colors: _cc),
    ]));
  });
}

class _HoursCard extends ConsumerWidget {
  const _HoursCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref.watch(supplyHoursProvider).when(loading: () => _loading(), error: (e, _) => _err(e), data: (data) {
    final c = _cm(data); if (c?.requested == null) return const SizedBox.shrink();
    return _Card(title: 'Часы работы', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Big(value: _fH(c!.requested!.summary ?? 0), diff: c.summaryDiffPercent),
      if (_nc(data).isNotEmpty) ...[const SizedBox(height: 8), _Badges(items: _nc(data), fmt: (v) => _fH(v))],
      const SizedBox(height: 12), _lineChart(spots: _spots(c, div: 3600), prev: _prev(c, div: 3600), labels: _lb(c), yFmt: (v) => '${v.toInt()} ч'),
    ]));
  });
}

class _ProfitCard extends ConsumerWidget {
  const _ProfitCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref.watch(profitProvider).when(loading: () => _loading(), error: (e, _) => _err(e), data: (data) {
    final c = _cm(data); if (c?.requested == null) return const SizedBox.shrink();
    return _Card(title: 'Доход таксопарка', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Big(value: _fM(c!.requested!.summary ?? 0), diff: c.summaryDiffPercent),
      const SizedBox(height: 12), _lineChart(spots: _spots(c), prev: _prev(c), labels: _lb(c)),
    ]));
  });
}

class _SumCard extends ConsumerWidget {
  const _SumCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref.watch(ordersSumProvider).when(loading: () => _loading(), error: (e, _) => _err(e), data: (data) {
    final c = _cm(data); if (c?.requested == null) return const SizedBox.shrink();
    return _Card(title: 'Сумма по поездкам', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Big(value: _fM(c!.requested!.summary ?? 0), diff: c.summaryDiffPercent),
      if (_nc(data).isNotEmpty) ...[const SizedBox(height: 8), _Badges(items: _nc(data), fmt: (v) => _fM(v))],
      const SizedBox(height: 12), _lineChart(spots: _spots(c), prev: _prev(c), labels: _lb(c)),
    ]));
  });
}

class _OrdersCard extends ConsumerWidget {
  const _OrdersCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref.watch(ordersByStatusProvider).when(loading: () => _loading(), error: (e, _) => _err(e), data: (data) {
    final c = _cm(data); if (c?.requested == null) return const SizedBox.shrink();
    final ss = data.series.where((s) => s.id == 'successful' || s.id == 'driver_cancelled' || s.id == 'client_cancelled').toList();
    return _Card(title: 'Заказы', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Big(value: (c!.requested!.summary ?? 0).toInt().toString()),
      const SizedBox(height: 12), _stackBar(series: ss, labels: _lb(c)),
    ]));
  });
}

class _PayCard extends ConsumerWidget {
  const _PayCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref.watch(ordersByPaymentProvider).when(loading: () => _loading(), error: (e, _) => _err(e), data: (data) {
    final nc = _nc(data).where((s) => s.requested != null && s.requested!.values.isNotEmpty).toList();
    if (nc.isEmpty) return const SizedBox.shrink();
    final legend = nc.asMap().entries.map((e) => MapEntry(e.value.name ?? e.value.id, _cc[e.key % _cc.length])).toList();
    return _Card(title: 'Способ оплаты', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Legend(items: legend), const SizedBox(height: 12), _multiLine(series: nc, labels: _lb(nc.first), colors: _cc),
    ]));
  });
}

class _CertCard extends ConsumerWidget {
  const _CertCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref.watch(certificationProvider).when(loading: () => _loading(), error: (e, _) => _err(e), data: (data) {
    final cert = data['certification'] as Map<String, dynamic>? ?? {};
    final ok = cert['is_certified'] == true;
    final pts = data['certification_points'] as List? ?? [];
    return _Card(title: 'Сертификация', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(ok ? 'Вы сертифицированный партнёр' : 'Вы не сертифицированный\nпартнёр',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Yandex Sans Text', height: 1.2)),
      const SizedBox(height: 12),
      ...pts.map((p) {
        final m = p as Map<String, dynamic>; final passed = m['is_passed'] == true;
        final items = m['items'] as List? ?? []; final name = items.isNotEmpty ? (items[0] as Map)['name'] ?? '' : '';
        return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(passed ? Icons.check : Icons.close, size: 16, color: passed ? const Color(0xFF00B341) : AppTheme.textSecondary),
          const SizedBox(width: 8),
          Expanded(child: Text(_certLbl(name as String, items.isNotEmpty ? items[0] as Map : {}), style: const TextStyle(fontSize: 13, fontFamily: 'Yandex Sans Text'))),
        ]));
      }),
    ]));
  });
  static String _certLbl(String n, Map i) => switch (n) {
    'monthly_rides_in_quarter' => 'Поездки в каждом месяце квартала',
    'share_of_bad_grades' => 'Доля низких оценок меньше — ${i['threshold'] ?? 0} %',
    'active_contractors' => 'Количество активных исполнителей больше — ${i['value'] ?? 0}',
    'churn' => 'Отток водителей',
    'sh_per_driver' => 'Часы на линии на водителя',
    'filled_correct_contacts' => 'Заполнены корректные контакты',
    _ => n,
  };
}

