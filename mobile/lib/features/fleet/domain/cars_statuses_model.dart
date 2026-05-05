class CarsStatusesResponse {
  final List<CarsStatusSeries> series;

  CarsStatusesResponse({required this.series});

  factory CarsStatusesResponse.fromJson(Map<String, dynamic> json) {
    final seriesList = json['series'] as List? ?? [];
    return CarsStatusesResponse(
      series: seriesList.map((e) => CarsStatusSeries.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class CarsStatusSeries {
  final String id;
  final String name;
  final List<CarsStatusPoint> values;

  CarsStatusSeries({
    required this.id,
    required this.name,
    required this.values,
  });

  factory CarsStatusSeries.fromJson(Map<String, dynamic> json) {
    final valuesList = json['values'] as List? ?? [];
    return CarsStatusSeries(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      values: valuesList.map((e) => CarsStatusPoint.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class CarsStatusPoint {
  final String x;
  final double y;

  CarsStatusPoint({required this.x, required this.y});

  factory CarsStatusPoint.fromJson(Map<String, dynamic> json) {
    return CarsStatusPoint(
      x: json['x'] as String? ?? '',
      y: (json['y'] ?? 0).toDouble(),
    );
  }
}
