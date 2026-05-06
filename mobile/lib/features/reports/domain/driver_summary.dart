class DriverSummaryDriver {
  final String id;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String licenseNumber;
  final String workRuleId;

  const DriverSummaryDriver({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.licenseNumber,
    required this.workRuleId,
  });

  factory DriverSummaryDriver.fromJson(Map<String, dynamic> json) {
    return DriverSummaryDriver(
      id: json['id'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      middleName: json['middle_name'] as String?,
      licenseNumber: json['license_number'] as String? ?? '',
      workRuleId: json['work_rule_id'] as String? ?? '',
    );
  }

  String get fullName {
    final parts = [lastName, firstName, middleName]
        .where((p) => p != null && p.isNotEmpty)
        .join(' ');
    return parts.isNotEmpty ? parts : id;
  }

  String get shortName {
    if (lastName.isNotEmpty && firstName.isNotEmpty) {
      return '$lastName ${firstName[0]}.${middleName != null && middleName!.isNotEmpty ? ' ${middleName![0]}.' : ''}';
    }
    return fullName;
  }
}

class DriverSummaryCar {
  final String callsign;
  const DriverSummaryCar({required this.callsign});
  factory DriverSummaryCar.fromJson(Map<String, dynamic> json) =>
      DriverSummaryCar(callsign: json['callsign'] as String? ?? '');
}

class DriverSummaryCarDetail {
  final String id;
  final String brand;
  final String model;
  final String number;
  const DriverSummaryCarDetail({
    required this.id,
    required this.brand,
    required this.model,
    required this.number,
  });
  factory DriverSummaryCarDetail.fromJson(Map<String, dynamic> json) =>
      DriverSummaryCarDetail(
        id: json['id'] as String? ?? '',
        brand: json['brand'] as String? ?? '',
        model: json['model'] as String? ?? '',
        number: json['number'] as String? ?? '',
      );
  String get displayName => '$brand $model'.trim();
}

class DriverSummaryItem {
  final DriverSummaryDriver driver;
  final DriverSummaryCar car;
  final int countOrdersCompleted;
  final int countOrdersAll;
  final double? completionRate;
  final int countOrdersPlatform;
  final int countOrdersAccepted;
  final int countOrdersCancelledByDriver;
  final int countOrdersCancelledByClient;
  final int workTimeSeconds;
  final double priceCash;
  final double priceCashless;
  final double pricePlatformCommission;
  final double priceParkCommission;
  final double priceOtherGas;
  final double distance;
  final List<DriverSummaryCarDetail> cars;
  final double tripsPerHour;
  final double? acceptanceRate;

  const DriverSummaryItem({
    required this.driver,
    required this.car,
    required this.countOrdersCompleted,
    required this.countOrdersAll,
    this.completionRate,
    required this.countOrdersPlatform,
    required this.countOrdersAccepted,
    required this.countOrdersCancelledByDriver,
    required this.countOrdersCancelledByClient,
    required this.workTimeSeconds,
    required this.priceCash,
    required this.priceCashless,
    required this.pricePlatformCommission,
    required this.priceParkCommission,
    required this.priceOtherGas,
    required this.distance,
    required this.cars,
    required this.tripsPerHour,
    this.acceptanceRate,
  });

  factory DriverSummaryItem.fromJson(Map<String, dynamic> json) {
    return DriverSummaryItem(
      driver: DriverSummaryDriver.fromJson(json['driver'] as Map<String, dynamic>),
      car: DriverSummaryCar.fromJson(json['car'] as Map<String, dynamic>? ?? {}),
      countOrdersCompleted: (json['count_orders_completed'] as num?)?.toInt() ?? 0,
      countOrdersAll: (json['count_orders_all'] as num?)?.toInt() ?? 0,
      completionRate: (json['completion_rate'] as num?)?.toDouble(),
      countOrdersPlatform: (json['count_orders_platform'] as num?)?.toInt() ?? 0,
      countOrdersAccepted: (json['count_orders_accepted'] as num?)?.toInt() ?? 0,
      countOrdersCancelledByDriver: (json['count_orders_cancelled_by_driver'] as num?)?.toInt() ?? 0,
      countOrdersCancelledByClient: (json['count_orders_cancelled_by_client'] as num?)?.toInt() ?? 0,
      workTimeSeconds: (json['work_time_seconds'] as num?)?.toInt() ?? 0,
      priceCash: (json['price_cash'] as num?)?.toDouble() ?? 0.0,
      priceCashless: (json['price_cashless'] as num?)?.toDouble() ?? 0.0,
      pricePlatformCommission: (json['price_platform_commission'] as num?)?.toDouble() ?? 0.0,
      priceParkCommission: (json['price_park_commission'] as num?)?.toDouble() ?? 0.0,
      priceOtherGas: (json['price_other_gas'] as num?)?.toDouble() ?? 0.0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      cars: (json['cars'] as List<dynamic>?)
              ?.map((e) => DriverSummaryCarDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tripsPerHour: (json['trips_per_hour'] as num?)?.toDouble() ?? 0.0,
      acceptanceRate: (json['acceptance_rate'] as num?)?.toDouble(),
    );
  }

  String get workTimeFormatted {
    final h = workTimeSeconds ~/ 3600;
    final m = (workTimeSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}ч ${m}мин';
    return '${m}мин';
  }
}

class DriverSummaryTotal {
  final double? acceptanceRate;
  final double? completionRate;
  final int countActiveDrivers;
  final int countDrivers;
  final int countOrdersAccepted;
  final int countOrdersAll;
  final int countOrdersCancelledByClient;
  final int countOrdersCancelledByDriver;
  final int countOrdersCompleted;
  final int countOrdersPlatform;
  final double sumDistance;
  final int sumOrdersCompleted;
  final double sumPriceCash;
  final double sumPriceCashless;
  final double sumPriceOtherGas;
  final double sumPriceParkCommission;
  final double sumPricePlatformCommission;
  final int sumWorkTimeSeconds;
  final double tripsPerHour;

  const DriverSummaryTotal({
    this.acceptanceRate,
    this.completionRate,
    required this.countActiveDrivers,
    required this.countDrivers,
    required this.countOrdersAccepted,
    required this.countOrdersAll,
    required this.countOrdersCancelledByClient,
    required this.countOrdersCancelledByDriver,
    required this.countOrdersCompleted,
    required this.countOrdersPlatform,
    required this.sumDistance,
    required this.sumOrdersCompleted,
    required this.sumPriceCash,
    required this.sumPriceCashless,
    required this.sumPriceOtherGas,
    required this.sumPriceParkCommission,
    required this.sumPricePlatformCommission,
    required this.sumWorkTimeSeconds,
    required this.tripsPerHour,
  });

  factory DriverSummaryTotal.fromJson(Map<String, dynamic> json) {
    return DriverSummaryTotal(
      acceptanceRate: (json['acceptance_rate'] as num?)?.toDouble(),
      completionRate: (json['completion_rate'] as num?)?.toDouble(),
      countActiveDrivers: (json['count_active_drivers'] as num?)?.toInt() ?? 0,
      countDrivers: (json['count_drivers'] as num?)?.toInt() ?? 0,
      countOrdersAccepted: (json['count_orders_accepted'] as num?)?.toInt() ?? 0,
      countOrdersAll: (json['count_orders_all'] as num?)?.toInt() ?? 0,
      countOrdersCancelledByClient: (json['count_orders_cancelled_by_client'] as num?)?.toInt() ?? 0,
      countOrdersCancelledByDriver: (json['count_orders_cancelled_by_driver'] as num?)?.toInt() ?? 0,
      countOrdersCompleted: (json['count_orders_completed'] as num?)?.toInt() ?? 0,
      countOrdersPlatform: (json['count_orders_platform'] as num?)?.toInt() ?? 0,
      sumDistance: (json['sum_distance'] as num?)?.toDouble() ?? 0.0,
      sumOrdersCompleted: (json['sum_orders_completed'] as num?)?.toInt() ?? 0,
      sumPriceCash: (json['sum_price_cash'] as num?)?.toDouble() ?? 0.0,
      sumPriceCashless: (json['sum_price_cashless'] as num?)?.toDouble() ?? 0.0,
      sumPriceOtherGas: (json['sum_price_other_gas'] as num?)?.toDouble() ?? 0.0,
      sumPriceParkCommission: (json['sum_price_park_commission'] as num?)?.toDouble() ?? 0.0,
      sumPricePlatformCommission: (json['sum_price_platform_commission'] as num?)?.toDouble() ?? 0.0,
      sumWorkTimeSeconds: (json['sum_work_time_seconds'] as num?)?.toInt() ?? 0,
      tripsPerHour: (json['trips_per_hour'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get workTimeFormatted {
    final h = sumWorkTimeSeconds ~/ 3600;
    final m = (sumWorkTimeSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}ч ${m}мин';
    return '${m}мин';
  }
}

class DriverSummaryResponse {
  final List<DriverSummaryItem> items;
  final DriverSummaryTotal total;

  const DriverSummaryResponse({
    required this.items,
    required this.total,
  });

  factory DriverSummaryResponse.fromJson(Map<String, dynamic> json) {
    return DriverSummaryResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => DriverSummaryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: DriverSummaryTotal.fromJson(
          json['total'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class SortOption {
  final String field;
  final String label;
  const SortOption(this.field, this.label);
}

const kSortOptions = [
  SortOption('driver_id', 'По исполнителю'),
  SortOption('work_time_seconds', 'По времени'),
  SortOption('count_orders_completed', 'По заказам'),
  SortOption('price_cash', 'По наличным'),
  SortOption('price_cashless', 'По безналичным'),
  SortOption('price_platform_commission', 'По ком. платф.'),
  SortOption('price_park_commission', 'По ком. парка'),
];

class SummaryReportFilter {
  final DateTime dateFrom;
  final DateTime dateTo;
  final String? driverId;
  final String? driverName;
  final String? workRuleId;
  final String? workRuleName;
  final String sortField;
  final String sortDirection;

  SummaryReportFilter({
    required this.dateFrom,
    required this.dateTo,
    this.driverId,
    this.driverName,
    this.workRuleId,
    this.workRuleName,
    this.sortField = 'driver_id',
    this.sortDirection = 'asc',
  });

  static SummaryReportFilter get defaultFilter {
    final now = DateTime.now();
    final to = DateTime(now.year, now.month, now.day);
    final from = to.subtract(const Duration(days: 7));
    return SummaryReportFilter(dateFrom: from, dateTo: to);
  }

  SummaryReportFilter copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? driverId,
    String? driverName,
    bool clearDriver = false,
    String? workRuleId,
    String? workRuleName,
    bool clearWorkRule = false,
    String? sortField,
    String? sortDirection,
  }) {
    return SummaryReportFilter(
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      driverId: clearDriver ? null : (driverId ?? this.driverId),
      driverName: clearDriver ? null : (driverName ?? this.driverName),
      workRuleId: clearWorkRule ? null : (workRuleId ?? this.workRuleId),
      workRuleName: clearWorkRule ? null : (workRuleName ?? this.workRuleName),
      sortField: sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }

  String get sortLabel {
    try {
      return kSortOptions.firstWhere((o) => o.field == sortField).label;
    } catch (_) {
      return sortField;
    }
  }

  String get dateFromFormatted =>
      '${dateFrom.year}-${dateFrom.month.toString().padLeft(2, '0')}-${dateFrom.day.toString().padLeft(2, '0')}';

  String get dateToFormatted =>
      '${dateTo.year}-${dateTo.month.toString().padLeft(2, '0')}-${dateTo.day.toString().padLeft(2, '0')}';

  String get dateRangeLabel {
    String _fmt(DateTime d) =>
        '${d.day} ${_monthShort(d.month)} — ${dateTo.day} ${_monthShort(dateTo.month)}';
    return _fmt(dateFrom);
  }

  static String _monthShort(int m) {
    const months = ['', 'янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    return months[m];
  }
}
