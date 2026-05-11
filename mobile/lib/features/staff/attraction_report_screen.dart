import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/staff/data/staff_repository.dart';
import 'package:mobile/shared/widgets/custom_date_range_picker_bottom_sheet.dart';
import 'dart:math' as math;

class AttractionReportScreen extends ConsumerStatefulWidget {
  const AttractionReportScreen({super.key});

  @override
  ConsumerState<AttractionReportScreen> createState() =>
      _AttractionReportScreenState();
}

class _AttractionReportScreenState
    extends ConsumerState<AttractionReportScreen> {
  DateTime _dateFrom = DateTime.now().subtract(const Duration(days: 30));
  DateTime _dateTo = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final params = AttractionReportParams(from: _dateFrom, to: _dateTo);
    final reportAsync = ref.watch(attractionReportProvider(params));

    final dateFormatter = DateFormat('d MMM', 'ru');
    final dateRangeStr =
        '${dateFormatter.format(_dateFrom)} – ${dateFormatter.format(_dateTo)}';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Отчет по привлечению'),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF5F5F5),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Поиск',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final range = await CustomDateRangePickerBottomSheet.show(
                        context: context,
                        title: 'Выберите период',
                        startDate: _dateFrom,
                        endDate: _dateTo,
                      );
                      if (range != null) {
                        setState(() {
                          _dateFrom = range.start;
                          _dateTo = range.end;
                        });
                      }
                    },
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Colors.black87),
                          const SizedBox(width: 6),
                          Text(
                            dateRangeStr,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down,
                              size: 16, color: Colors.black87),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          reportAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => SliverFillRemaining(
              child: Center(child: Text('Ошибка: $e')),
            ),
            data: (data) {
              return SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Сколько\nвсего зарег\nистрирова\nлось',
                              '${data['leads_count'] ?? 0}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'Конверсия\nв первый\nзаказ',
                              '${data['first_trip']?['conversion'] ?? 0}%',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'Конверсия\nв 50-ый\nзаказ',
                              '${data['fiftieth_trip']?['conversion'] ?? 0}%',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTable(data['sources'] as List<dynamic>? ?? [], context),
                  const SizedBox(height: 32),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.replaceAll('\n', ' '), // Keep text clean, just use standard wrap
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<dynamic> sources, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Каналы',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _buildSortHeader('Привлечённые\nкандидаты'),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          // Rows
          ...sources.map((s) {
            final sourceData = s['source_data'] as Map<String, dynamic>? ?? {};
            return _buildTableRow(context, sourceData);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSortHeader(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Column(
          children: [
            Icon(Icons.arrow_upward, size: 10, color: Colors.grey),
            Icon(Icons.arrow_downward, size: 10, color: Colors.grey),
          ],
        ),
      ],
    );
  }

  Widget _buildTableRow(BuildContext context, Map<String, dynamic> sourceData) {
    final name = sourceData['name']?.toString() ?? '';
    final id = sourceData['id']?.toString() ?? '';
    final leadsCount = sourceData['leads_count']?.toString() ?? '0';

    Widget icon;
    if (id == 'yandex') {
      icon = Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text('Я', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
      );
    } else {
      icon = const Icon(Icons.phone_iphone, size: 16);
    }

    return Column(
      children: [
        InkWell(
          onTap: () => _showSourceDetails(context, sourceData),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      icon,
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    leadsCount,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }

  void _showSourceDetails(BuildContext context, Map<String, dynamic> sourceData) {
    final name = sourceData['name']?.toString() ?? '';
    final sourceId = sourceData['id']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return _SourceDetailsBottomSheet(
          sourceId: sourceId,
          sourceName: name,
          from: _dateFrom,
          to: _dateTo,
        );
      },
    );
  }
}

class _SourceDetailsBottomSheet extends ConsumerWidget {
  final String sourceId;
  final String sourceName;
  final DateTime from;
  final DateTime to;

  const _SourceDetailsBottomSheet({
    required this.sourceId,
    required this.sourceName,
    required this.from,
    required this.to,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = AttractionSourceReportParams(
      from: from,
      to: to,
      sourceId: sourceId,
    );
    final reportAsync = ref.watch(attractionSourceReportProvider(params));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    sourceName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            reportAsync.when(
              data: (data) {
                final contractorsCount = data['contractors_count']?.toString() ?? '0';
                final ordersCount = data['orders_count']?.toString() ?? '0';
                
                final funnel = data['funnel'] as List<dynamic>? ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildBadge(Icons.person_outline, '$contractorsCount исполнителей'),
                        const SizedBox(width: 8),
                        _buildBadge(Icons.route, '$ordersCount заказов'),
                      ],
                    ),
                    const SizedBox(height: 32),
                    if (funnel.isNotEmpty) _buildFunnelChart(funnel),
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 250, 
                child: Center(child: CircularProgressIndicator())
              ),
              error: (err, stack) => SizedBox(
                height: 250, 
                child: Center(child: Text('Ошибка: $err'))
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _getStageName(String stage) {
    switch (stage) {
      case 'lead': return 'Лиды';
      case 'contractor': return 'Регистрации';
      case 'first_trip': return 'Первый заказ';
      case 'fiftieth_trip': return '50-ый заказ';
      default: return stage;
    }
  }

  Widget _buildFunnelChart(List<dynamic> funnel) {
    double maxCount = 0;
    for (var item in funnel) {
      final count = (item['count'] as num?)?.toDouble() ?? 0.0;
      if (count > maxCount) maxCount = count;
    }
    
    return SizedBox(
      height: 250,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(funnel.length, (index) {
          final item = funnel[index];
          final count = (item['count'] as num?)?.toDouble() ?? 0.0;
          final nextCount = index < funnel.length - 1 
              ? ((funnel[index + 1]['count'] as num?)?.toDouble() ?? 0.0) 
              : count;
              
          final stage = item['stage'] as String? ?? '';
          final name = _getStageName(stage);
          
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < funnel.length - 1 ? 2.0 : 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  Text('${count.toInt()} исполнителей', style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.horizontal(
                        left: index == 0 ? const Radius.circular(6) : Radius.zero,
                        right: index == funnel.length - 1 ? const Radius.circular(6) : Radius.zero,
                      ),
                      child: CustomPaint(
                        painter: _FunnelBlockPainter(
                          count: count,
                          nextCount: nextCount,
                          maxCount: maxCount == 0 ? 1 : maxCount,
                        ),
                        child: Container(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FunnelBlockPainter extends CustomPainter {
  final double count;
  final double nextCount;
  final double maxCount;

  _FunnelBlockPainter({
    required this.count,
    required this.nextCount,
    required this.maxCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1C75FF)
      ..style = PaintingStyle.fill;

    final hLeft = count == 0 ? 4.0 : math.max(4.0, (count / maxCount) * size.height);
    final hRight = nextCount == 0 ? 4.0 : math.max(4.0, (nextCount / maxCount) * size.height);

    final path = Path();
    path.moveTo(0, size.height - hLeft);
    path.cubicTo(
      size.width * 0.5, size.height - hLeft,
      size.width * 0.5, size.height - hRight,
      size.width, size.height - hRight,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FunnelBlockPainter oldDelegate) {
    return oldDelegate.count != count || 
           oldDelegate.nextCount != nextCount || 
           oldDelegate.maxCount != maxCount;
  }
}
