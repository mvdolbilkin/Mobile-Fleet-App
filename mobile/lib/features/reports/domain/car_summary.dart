class CarSortOption {
  final String field;
  final String label;
  const CarSortOption(this.field, this.label);
}

const kCarSortOptions = [
  CarSortOption('car_id', 'По автомобилю'),
  CarSortOption('utilization', 'По сдаваемости'),
  CarSortOption('count_orders_all', 'По заказам'),
  CarSortOption('price_cash', 'По наличным'),
  CarSortOption('price_cashless', 'По безналичным'),
  CarSortOption('price_rent', 'По аренде'),
  CarSortOption('distance', 'По пробегу'),
];

class CarSummaryDriver {
  final String id;
  final String firstName;
  final String lastName;
  final String? middleName;

  const CarSummaryDriver({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
  });

  String get fullName => '$lastName $firstName'.trim();

  String get initials {
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    return '$l$f';
  }

  factory CarSummaryDriver.fromJson(Map<String, dynamic> json) {
    return CarSummaryDriver(
      id: json['id'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      middleName: json['middle_name'] as String?,
    );
  }
}

class CarSummaryCarInfo {
  final String id;
  final String brand;
  final String model;
  final String color;
  final int year;
  final String number;
  final String callsign;
  final List<String> category;

  const CarSummaryCarInfo({
    required this.id,
    required this.brand,
    required this.model,
    required this.color,
    required this.year,
    required this.number,
    required this.callsign,
    required this.category,
  });

  String get displayName => '$brand $model';

  factory CarSummaryCarInfo.fromJson(Map<String, dynamic> json) {
    return CarSummaryCarInfo(
      id: json['id'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      color: json['color'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      number: json['number'] as String? ?? '',
      callsign: json['callsign'] as String? ?? '',
      category: (json['category'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class CarSummaryItem {
  final CarSummaryCarInfo car;
  final List<CarSummaryDriver> drivers;
  final List<String> activeCategory;
  final int utilization;
  final int utilizationDays;
  final int noUtilizationDays;
  final int countOrdersAll;
  final double priceCash;
  final double priceCashless;
  final double priceRent;
  final double rentWithdraw;
  final double rentWithhold;
  final double rentCancel;
  final double rentWithdrawWait;
  final double distance;

  const CarSummaryItem({
    required this.car,
    required this.drivers,
    required this.activeCategory,
    required this.utilization,
    required this.utilizationDays,
    required this.noUtilizationDays,
    required this.countOrdersAll,
    required this.priceCash,
    required this.priceCashless,
    required this.priceRent,
    required this.rentWithdraw,
    required this.rentWithhold,
    required this.rentCancel,
    required this.rentWithdrawWait,
    required this.distance,
  });

  String get distanceKm {
    final km = distance / 1000;
    if (km == 0) return '0';
    if (km == km.truncateToDouble()) return km.toInt().toString();
    return km.toStringAsFixed(1);
  }

  factory CarSummaryItem.fromJson(Map<String, dynamic> json) {
    return CarSummaryItem(
      car: CarSummaryCarInfo.fromJson(
          json['car'] as Map<String, dynamic>? ?? {}),
      drivers: (json['drivers'] as List<dynamic>?)
              ?.map((e) =>
                  CarSummaryDriver.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      activeCategory: (json['category'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      utilization: (json['utilization'] as num?)?.toInt() ?? 0,
      utilizationDays: (json['utilization_days'] as num?)?.toInt() ?? 0,
      noUtilizationDays:
          (json['no_utilization_days'] as num?)?.toInt() ?? 0,
      countOrdersAll: (json['count_orders_all'] as num?)?.toInt() ?? 0,
      priceCash: (json['price_cash'] as num?)?.toDouble() ?? 0,
      priceCashless: (json['price_cashless'] as num?)?.toDouble() ?? 0,
      priceRent: (json['price_rent'] as num?)?.toDouble() ?? 0,
      rentWithdraw: (json['rent_withdraw'] as num?)?.toDouble() ?? 0,
      rentWithhold: (json['rent_withhold'] as num?)?.toDouble() ?? 0,
      rentCancel: (json['rent_cancel'] as num?)?.toDouble() ?? 0,
      rentWithdrawWait:
          (json['rent_withdraw_wait'] as num?)?.toDouble() ?? 0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CarSummaryTotal {
  final int countCars;
  final int countDrivers;
  final int avgUtilization;
  final int countOrdersAll;
  final double sumPriceCash;
  final double sumPriceCashless;
  final double sumPriceRent;
  final double sumRentWithdraw;
  final double sumRentWithhold;
  final double sumRentCancel;
  final double sumRentWithdrawWait;
  final double sumDistance;

  const CarSummaryTotal({
    required this.countCars,
    required this.countDrivers,
    required this.avgUtilization,
    required this.countOrdersAll,
    required this.sumPriceCash,
    required this.sumPriceCashless,
    required this.sumPriceRent,
    required this.sumRentWithdraw,
    required this.sumRentWithhold,
    required this.sumRentCancel,
    required this.sumRentWithdrawWait,
    required this.sumDistance,
  });

  String get distanceKm {
    final km = sumDistance / 1000;
    if (km == 0) return '0';
    if (km == km.truncateToDouble()) return km.toInt().toString();
    return km.toStringAsFixed(1);
  }

  factory CarSummaryTotal.fromJson(Map<String, dynamic> json) {
    return CarSummaryTotal(
      countCars: (json['count_cars'] as num?)?.toInt() ?? 0,
      countDrivers: (json['count_drivers'] as num?)?.toInt() ?? 0,
      avgUtilization: (json['avg_utilization'] as num?)?.toInt() ?? 0,
      countOrdersAll: (json['count_orders_all'] as num?)?.toInt() ?? 0,
      sumPriceCash: (json['sum_price_cash'] as num?)?.toDouble() ?? 0,
      sumPriceCashless:
          (json['sum_price_cashless'] as num?)?.toDouble() ?? 0,
      sumPriceRent: (json['sum_price_rent'] as num?)?.toDouble() ?? 0,
      sumRentWithdraw:
          (json['sum_rent_withdraw'] as num?)?.toDouble() ?? 0,
      sumRentWithhold:
          (json['sum_rent_withhold'] as num?)?.toDouble() ?? 0,
      sumRentCancel: (json['sum_rent_cancel'] as num?)?.toDouble() ?? 0,
      sumRentWithdrawWait:
          (json['sum_rent_withdraw_wait'] as num?)?.toDouble() ?? 0,
      sumDistance: (json['sum_distance'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CarSummaryResponse {
  final List<CarSummaryItem> items;
  final CarSummaryTotal total;

  const CarSummaryResponse({
    required this.items,
    required this.total,
  });

  factory CarSummaryResponse.fromJson(Map<String, dynamic> json) {
    return CarSummaryResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) =>
                  CarSummaryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: CarSummaryTotal.fromJson(
          json['total'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class CarSummaryFilter {
  final DateTime dateFrom;
  final DateTime dateTo;
  final String sortField;
  final String sortDirection;

  CarSummaryFilter({
    required this.dateFrom,
    required this.dateTo,
    this.sortField = 'car_id',
    this.sortDirection = 'asc',
  });

  static CarSummaryFilter get defaultFilter {
    final now = DateTime.now();
    final to = DateTime(now.year, now.month, now.day);
    final from = to.subtract(const Duration(days: 7));
    return CarSummaryFilter(dateFrom: from, dateTo: to);
  }

  CarSummaryFilter copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? sortField,
    String? sortDirection,
  }) {
    return CarSummaryFilter(
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      sortField: sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }

  String get dateFromFormatted =>
      '${dateFrom.year}-${dateFrom.month.toString().padLeft(2, '0')}-${dateFrom.day.toString().padLeft(2, '0')}';

  String get dateToFormatted =>
      '${dateTo.year}-${dateTo.month.toString().padLeft(2, '0')}-${dateTo.day.toString().padLeft(2, '0')}';
}
