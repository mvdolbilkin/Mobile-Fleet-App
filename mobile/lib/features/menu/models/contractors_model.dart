class ContractorsData {
  final Indicator indicator;
  final MetricWithDiff newContractors;
  final MetricWithDiff churn;
  final AvgTimeOnline avgTimeOnline;
  final Conversion conversion;
  final RatingInfo ratingInfo;

  ContractorsData({
    required this.indicator,
    required this.newContractors,
    required this.churn,
    required this.avgTimeOnline,
    required this.conversion,
    required this.ratingInfo,
  });

  factory ContractorsData.fromJson(Map<String, dynamic> json) {
    return ContractorsData(
      indicator: Indicator.fromJson(json['indicator']),
      newContractors: MetricWithDiff.fromJson(json['new']),
      churn: MetricWithDiff.fromJson(json['churn']),
      avgTimeOnline: AvgTimeOnline.fromJson(json['avg_time_online']),
      conversion: Conversion.fromJson(json['conversion']),
      ratingInfo: RatingInfo.fromJson(json['rating_info']),
    );
  }
}

class Indicator {
  final int total;
  final int free;
  final int inOrder;
  final int busy;

  Indicator({
    required this.total,
    required this.free,
    required this.inOrder,
    required this.busy,
  });

  factory Indicator.fromJson(Map<String, dynamic> json) {
    return Indicator(
      total: json['total'],
      free: json['free'],
      inOrder: json['in_order'],
      busy: json['busy'],
    );
  }
}

class MetricWithDiff {
  final double current;
  final Diff diff;

  MetricWithDiff({required this.current, required this.diff});

  factory MetricWithDiff.fromJson(Map<String, dynamic> json) {
    return MetricWithDiff(
      current: (json['current'] as num).toDouble(),
      diff: Diff.fromJson(json['diff']),
    );
  }
}

class Diff {
  final double value;
  final bool isPercent;

  Diff({required this.value, required this.isPercent});

  factory Diff.fromJson(Map<String, dynamic> json) {
    return Diff(value: json['value'].toDouble(), isPercent: json['is_percent']);
  }

  String get formattedValue {
    final sign = value >= 0 ? '+' : '';
    if (isPercent) {
      return '$sign${value.toStringAsFixed(1)}%';
    }
    return '$sign${value.toStringAsFixed(0)}';
  }

  String get arrow {
    if (value > 0) return '↑';
    if (value < 0) return '↓';
    return '';
  }
}

class AvgTimeOnline {
  final int current; // in seconds

  AvgTimeOnline({required this.current});

  factory AvgTimeOnline.fromJson(Map<String, dynamic> json) {
    return AvgTimeOnline(current: json['current']);
  }

  String get formatted {
    final hours = current ~/ 3600;
    final minutes = (current % 3600) ~/ 60;
    return '$hours ч $minutes мин';
  }
}

class Conversion {
  final ConversionMetric oneTrip;
  final ConversionMetric nTrips;

  Conversion({required this.oneTrip, required this.nTrips});

  factory Conversion.fromJson(Map<String, dynamic> json) {
    return Conversion(
      oneTrip: ConversionMetric.fromJson(json['one_trip']),
      nTrips: ConversionMetric.fromJson(json['n_trips']),
    );
  }
}

class ConversionMetric {
  final int trips;
  final double current;
  final String status;

  ConversionMetric({
    required this.trips,
    required this.current,
    required this.status,
  });

  factory ConversionMetric.fromJson(Map<String, dynamic> json) {
    return ConversionMetric(
      trips: json['trips'],
      current: json['current'].toDouble(),
      status: json['status'],
    );
  }
}

class RatingInfo {
  final String rating;
  final RatingCategory ratingCategory;

  RatingInfo({required this.rating, required this.ratingCategory});

  factory RatingInfo.fromJson(Map<String, dynamic> json) {
    return RatingInfo(
      rating: json['rating'],
      ratingCategory: RatingCategory.fromJson(json['rating_category']),
    );
  }
}

class RatingCategory {
  final String categoryCode;
  final String text;

  RatingCategory({required this.categoryCode, required this.text});

  factory RatingCategory.fromJson(Map<String, dynamic> json) {
    return RatingCategory(
      categoryCode: json['category_code'],
      text: json['text'],
    );
  }

  bool get isBelowAverage => categoryCode == 'below_average';
  bool get isNotRanked => categoryCode == 'not_ranked';
}
