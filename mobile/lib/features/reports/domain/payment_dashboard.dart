class DashboardPoint {
  final String x;
  final double y;

  const DashboardPoint({required this.x, required this.y});

  factory DashboardPoint.fromJson(Map<String, dynamic> j) => DashboardPoint(
        x: j['x'] as String? ?? '',
        y: (j['y'] as num?)?.toDouble() ?? 0,
      );

  String get weekdayLabel {
    try {
      final d = DateTime.parse(x.substring(0, 10)).add(const Duration(hours: 3));
      const days = ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'];
      return '${days[d.weekday - 1]} ${d.day}';
    } catch (_) {
      return '';
    }
  }
}

class DashboardSummary {
  final double value;
  final double? diffValue;

  const DashboardSummary({required this.value, this.diffValue});

  factory DashboardSummary.fromJson(Map<String, dynamic> j) => DashboardSummary(
        value: (j['value'] as num?)?.toDouble() ?? 0,
        diffValue: j['diff_value'] != null
            ? (j['diff_value'] as num).toDouble()
            : null,
      );
}

class DashboardPeriod {
  final List<DashboardPoint> values;
  final DashboardSummary summary;

  const DashboardPeriod({required this.values, required this.summary});

  factory DashboardPeriod.fromJson(Map<String, dynamic> j) => DashboardPeriod(
        values: (j['values'] as List<dynamic>? ?? [])
            .map((e) => DashboardPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        summary: DashboardSummary.fromJson(
            j['summary'] as Map<String, dynamic>? ?? {}),
      );
}

class DashboardSeries {
  final String id;
  final String name;
  final String kind;
  final DashboardPeriod requested;
  final DashboardPeriod previous;

  const DashboardSeries({
    required this.id,
    required this.name,
    required this.kind,
    required this.requested,
    required this.previous,
  });

  factory DashboardSeries.fromJson(Map<String, dynamic> j) => DashboardSeries(
        id: j['id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        kind: j['kind'] as String? ?? 'line',
        requested: DashboardPeriod.fromJson(
            j['requested'] as Map<String, dynamic>? ?? {}),
        previous: DashboardPeriod.fromJson(
            j['previous'] as Map<String, dynamic>? ?? {}),
      );
}

class DashboardWidgetResponse {
  final List<DashboardSeries> series;

  const DashboardWidgetResponse({required this.series});

  DashboardSeries? get total {
    for (final s in series) {
      if (s.id == 'total') return s;
    }
    return series.isEmpty ? null : series.first;
  }

  factory DashboardWidgetResponse.fromJson(Map<String, dynamic> j) =>
      DashboardWidgetResponse(
        series: (j['series'] as List<dynamic>? ?? [])
            .map((e) => DashboardSeries.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class TransactionStatus {
  final String status;
  final double value;
  final String statusText;

  const TransactionStatus({
    required this.status,
    required this.value,
    required this.statusText,
  });

  factory TransactionStatus.fromJson(Map<String, dynamic> j) =>
      TransactionStatus(
        status: j['status_enum'] as String? ?? j['status'] as String? ?? '',
        value: (j['value'] as num?)?.toDouble() ?? 0,
        statusText: j['status_text'] as String? ?? '',
      );
}

class TransactionStatusesResponse {
  final double total;
  final List<TransactionStatus> statuses;

  const TransactionStatusesResponse({required this.total, required this.statuses});

  factory TransactionStatusesResponse.fromJson(Map<String, dynamic> j) =>
      TransactionStatusesResponse(
        total: (j['total'] as num?)?.toDouble() ?? 0,
        statuses: (j['statuses'] as List<dynamic>? ?? [])
            .map((e) => TransactionStatus.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class TransactionDriversResponse {
  final DashboardWidgetResponse topupWidget;
  final DashboardWidgetResponse payoutWidget;

  const TransactionDriversResponse({
    required this.topupWidget,
    required this.payoutWidget,
  });

  factory TransactionDriversResponse.fromJson(Map<String, dynamic> j) =>
      TransactionDriversResponse(
        topupWidget: DashboardWidgetResponse.fromJson(
            j['topup_widget'] as Map<String, dynamic>? ?? {}),
        payoutWidget: DashboardWidgetResponse.fromJson(
            j['payout_widget'] as Map<String, dynamic>? ?? {}),
      );
}
