class ParkSummaryItem {
  final String dateMonth;
  final int countActiveCars;
  final int countActiveDrivers;
  final int countOrdersCompleted;
  final int countOrdersAll;
  final int countOrdersPlatform;
  final int countOrdersAccepted;
  final int countOrdersCancelledByDriver;
  final int countOrdersCancelledByClient;
  final int countNewDrivers;
  final double ratioDriverChurn;
  final int workTimeSeconds;
  final int avgDriversWorkTimeSeconds;
  final int avgCarsWorkTimeSeconds;
  final double priceCash;
  final double priceCashless;
  final double pricePlatformCommission;
  final double priceParkCommission;
  final double priceSoftwareCommission;
  final double priceHiringServices;
  final double priceHiringReturnedIncVat;

  const ParkSummaryItem({
    required this.dateMonth,
    required this.countActiveCars,
    required this.countActiveDrivers,
    required this.countOrdersCompleted,
    required this.countOrdersAll,
    required this.countOrdersPlatform,
    required this.countOrdersAccepted,
    required this.countOrdersCancelledByDriver,
    required this.countOrdersCancelledByClient,
    required this.countNewDrivers,
    required this.ratioDriverChurn,
    required this.workTimeSeconds,
    required this.avgDriversWorkTimeSeconds,
    required this.avgCarsWorkTimeSeconds,
    required this.priceCash,
    required this.priceCashless,
    required this.pricePlatformCommission,
    required this.priceParkCommission,
    required this.priceSoftwareCommission,
    required this.priceHiringServices,
    required this.priceHiringReturnedIncVat,
  });

  static const _monthNames = [
    '', 'янв.', 'февр.', 'март', 'апр.', 'май',
    'июнь', 'июль', 'авг.', 'сент.', 'окт.', 'нояб.', 'дек.'
  ];

  String get monthLabel {
    final parts = dateMonth.split('-');
    if (parts.length != 2) return dateMonth;
    final month = int.tryParse(parts[1]) ?? 0;
    if (month < 1 || month > 12) return dateMonth;
    return '${_monthNames[month]} ${parts[0]}';
  }

  static String fmtSeconds(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return '${h}ч ${m}мин';
  }

  factory ParkSummaryItem.fromJson(Map<String, dynamic> json) {
    return ParkSummaryItem(
      dateMonth: json['date_month'] as String? ?? '',
      countActiveCars: (json['count_active_cars'] as num?)?.toInt() ?? 0,
      countActiveDrivers:
          (json['count_active_drivers'] as num?)?.toInt() ?? 0,
      countOrdersCompleted:
          (json['count_orders_completed'] as num?)?.toInt() ?? 0,
      countOrdersAll: (json['count_orders_all'] as num?)?.toInt() ?? 0,
      countOrdersPlatform:
          (json['count_orders_platform'] as num?)?.toInt() ?? 0,
      countOrdersAccepted:
          (json['count_orders_accepted'] as num?)?.toInt() ?? 0,
      countOrdersCancelledByDriver:
          (json['count_orders_cancelled_by_driver'] as num?)?.toInt() ?? 0,
      countOrdersCancelledByClient:
          (json['count_orders_cancelled_by_client'] as num?)?.toInt() ?? 0,
      countNewDrivers: (json['count_new_drivers'] as num?)?.toInt() ?? 0,
      ratioDriverChurn:
          (json['ratio_driver_churn'] as num?)?.toDouble() ?? 0,
      workTimeSeconds: (json['work_time_seconds'] as num?)?.toInt() ?? 0,
      avgDriversWorkTimeSeconds:
          (json['avg_drivers_work_time_seconds'] as num?)?.toInt() ?? 0,
      avgCarsWorkTimeSeconds:
          (json['avg_cars_work_time_seconds'] as num?)?.toInt() ?? 0,
      priceCash: (json['price_cash'] as num?)?.toDouble() ?? 0,
      priceCashless: (json['price_cashless'] as num?)?.toDouble() ?? 0,
      pricePlatformCommission:
          (json['price_platform_commission'] as num?)?.toDouble() ?? 0,
      priceParkCommission:
          (json['price_park_commission'] as num?)?.toDouble() ?? 0,
      priceSoftwareCommission:
          (json['price_software_commission'] as num?)?.toDouble() ?? 0,
      priceHiringServices:
          (json['price_hiring_services'] as num?)?.toDouble() ?? 0,
      priceHiringReturnedIncVat:
          (json['price_hiring_returned_inc_vat'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ParkSummaryResponse {
  final List<ParkSummaryItem> items;

  const ParkSummaryResponse({required this.items});

  factory ParkSummaryResponse.fromJson(Map<String, dynamic> json) {
    return ParkSummaryResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) =>
                  ParkSummaryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
