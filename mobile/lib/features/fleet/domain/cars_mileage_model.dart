class CarsMileageResponse {
  final List<CarsMileageSeries> series;

  CarsMileageResponse({required this.series});

  factory CarsMileageResponse.fromJson(Map<String, dynamic> json) {
    final list = json['series'] as List? ?? [];
    return CarsMileageResponse(
      series: list.map((e) => CarsMileageSeries.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class CarsMileageSeries {
  final String id;
  final String? name;
  final MileageData? requested;
  final MileageData? previous;
  final double? summaryDiffPercent;

  CarsMileageSeries({
    required this.id,
    this.name,
    this.requested,
    this.previous,
    this.summaryDiffPercent,
  });

  factory CarsMileageSeries.fromJson(Map<String, dynamic> json) {
    return CarsMileageSeries(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
      requested: json['requested'] != null
          ? MileageData.fromJson(json['requested'] as Map<String, dynamic>)
          : null,
      previous: json['previous'] != null
          ? MileageData.fromJson(json['previous'] as Map<String, dynamic>)
          : null,
      summaryDiffPercent: (json['summary_diff_percent'] as num?)?.toDouble(),
    );
  }
}

class MileageData {
  final List<MileagePoint> values;
  final double? summary;

  MileageData({required this.values, this.summary});

  factory MileageData.fromJson(Map<String, dynamic> json) {
    final list = json['values'] as List? ?? [];
    return MileageData(
      values: list.map((e) => MileagePoint.fromJson(e as Map<String, dynamic>)).toList(),
      summary: (json['summary'] as num?)?.toDouble(),
    );
  }
}

class MileagePoint {
  final String x;
  final double y;

  MileagePoint({required this.x, required this.y});

  factory MileagePoint.fromJson(Map<String, dynamic> json) {
    return MileagePoint(
      x: json['x'] as String? ?? '',
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
