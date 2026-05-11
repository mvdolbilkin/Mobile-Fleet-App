class ActiveDriversResponse {
  final List<ActiveDriversSeries> series;

  ActiveDriversResponse({required this.series});

  factory ActiveDriversResponse.fromJson(Map<String, dynamic> json) {
    var seriesList = json['series'] as List? ?? [];
    return ActiveDriversResponse(
      series: seriesList.map((e) => ActiveDriversSeries.fromJson(e)).toList(),
    );
  }
}

class ActiveDriversSeries {
  final String id;
  final String? name;
  final SeriesData? requested;
  final SeriesData? previous;
  final double? summaryDiffPercent;

  ActiveDriversSeries({
    required this.id,
    this.name,
    this.requested,
    this.previous,
    this.summaryDiffPercent,
  });

  factory ActiveDriversSeries.fromJson(Map<String, dynamic> json) {
    return ActiveDriversSeries(
      id: json['id'] ?? '',
      name: json['name'],
      requested: json['requested'] != null ? SeriesData.fromJson(json['requested']) : null,
      previous: json['previous'] != null ? SeriesData.fromJson(json['previous']) : null,
      summaryDiffPercent: json['summary_diff_percent']?.toDouble(),
    );
  }
  
  // Backward compatibility getter
  String get category => id;
}

class SeriesData {
  final List<ChartPoint> values;
  final double? summary;

  SeriesData({
    required this.values,
    this.summary,
  });

  factory SeriesData.fromJson(Map<String, dynamic> json) {
    var valuesList = json['values'] as List? ?? [];
    return SeriesData(
      values: valuesList.map((e) => ChartPoint.fromJson(e)).toList(),
      summary: (json['summary'] as num?)?.toDouble(),
    );
  }
  
  // Backward compatibility getter
  List<ChartPoint> get chart => values;
}

class ChartPoint {
  final String x;
  final double y;

  ChartPoint({
    required this.x,
    required this.y,
  });

  factory ChartPoint.fromJson(Map<String, dynamic> json) {
    return ChartPoint(
      x: json['x'] ?? '',
      y: (json['y'] ?? 0).toDouble(),
    );
  }

  String get weekdayLabel {
    try {
      final dt = DateTime.parse(x);
      const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
      return days[dt.weekday - 1];
    } catch (_) {
      return '';
    }
  }
}
