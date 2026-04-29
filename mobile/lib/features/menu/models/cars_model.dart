class CarsData {
  final CarsIndicator indicator;
  final MetricWithDiff rentalRevenue;
  final SimpleMetric expenses;
  final MetricWithDiff profit;

  CarsData({
    required this.indicator,
    required this.rentalRevenue,
    required this.expenses,
    required this.profit,
  });

  factory CarsData.fromJson(Map<String, dynamic> json) {
    return CarsData(
      indicator: CarsIndicator.fromJson(json['indicator']),
      rentalRevenue: MetricWithDiff.fromJson(json['rental_revenue']),
      expenses: SimpleMetric.fromJson(json['expenses']),
      profit: MetricWithDiff.fromJson(json['profit']),
    );
  }
}

class CarsIndicator {
  final int total;
  final CarStatusDetail unknown;
  final CarStatusDetail working;
  final CarStatusDetail repairing;
  final CarStatusDetail noDriver;
  final CarStatusDetail pending;

  CarsIndicator({
    required this.total,
    required this.unknown,
    required this.working,
    required this.repairing,
    required this.noDriver,
    required this.pending,
  });

  factory CarsIndicator.fromJson(Map<String, dynamic> json) {
    return CarsIndicator(
      total: json['total'],
      unknown: CarStatusDetail.fromJson(json['unknown']),
      working: CarStatusDetail.fromJson(json['working']),
      repairing: CarStatusDetail.fromJson(json['repairing']),
      noDriver: CarStatusDetail.fromJson(json['no_driver']),
      pending: CarStatusDetail.fromJson(json['pending']),
    );
  }
}

class CarStatusDetail {
  final String name;
  final int count;

  CarStatusDetail({required this.name, required this.count});

  factory CarStatusDetail.fromJson(Map<String, dynamic> json) {
    return CarStatusDetail(name: json['name'], count: json['count']);
  }
}

class SimpleMetric {
  final int current;

  SimpleMetric({required this.current});

  factory SimpleMetric.fromJson(Map<String, dynamic> json) {
    return SimpleMetric(current: json['current']);
  }

  String get formatted {
    return _formatCurrency(current);
  }
}

class MetricWithDiff {
  final int current;
  final DiffValue diff;

  MetricWithDiff({required this.current, required this.diff});

  factory MetricWithDiff.fromJson(Map<String, dynamic> json) {
    return MetricWithDiff(
      current: json['current'],
      diff: DiffValue.fromJson(json['diff']),
    );
  }

  String get formatted {
    return _formatCurrency(current);
  }
}

class DiffValue {
  final double value;
  final bool isPercent;

  DiffValue({required this.value, required this.isPercent});

  factory DiffValue.fromJson(Map<String, dynamic> json) {
    return DiffValue(
      value: json['value'].toDouble(),
      isPercent: json['is_percent'],
    );
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

String _formatCurrency(int value) {
  if (value >= 1000000) {
    final millions = value / 1000000;
    return '${millions.toStringAsFixed(1)} млн ₽';
  } else if (value >= 1000) {
    final thousands = value / 1000;
    return '${thousands.toStringAsFixed(0)} тыс ₽';
  }
  return '$value ₽';
}
