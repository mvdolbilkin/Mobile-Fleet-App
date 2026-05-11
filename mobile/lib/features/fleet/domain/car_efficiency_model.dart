class CarEfficiencyResponse {
  final List<CarEfficiencyItem> items;
  final EfficiencyPagination pagination;

  const CarEfficiencyResponse({
    required this.items,
    required this.pagination,
  });

  factory CarEfficiencyResponse.fromJson(Map<String, dynamic> json) {
    return CarEfficiencyResponse(
      items: (json['items'] as List? ?? [])
          .map((e) => CarEfficiencyItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: EfficiencyPagination.fromJson(
          json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class CarEfficiencyItem {
  final CarInfo car;
  final List<DriverInfo> drivers;
  final List<DailyStatus> dailyStatuses;
  final int successOrdersCount;
  final int supplyTimeSeconds;
  final double? acceptanceRate;
  final double? completionRate;
  final double tripsPerHour;
  final double? driverCancellationRate;
  final double mileageOnLine;
  final double mileageOnOrder;
  final double idleMileage;

  const CarEfficiencyItem({
    required this.car,
    required this.drivers,
    required this.dailyStatuses,
    required this.successOrdersCount,
    required this.supplyTimeSeconds,
    this.acceptanceRate,
    this.completionRate,
    required this.tripsPerHour,
    this.driverCancellationRate,
    required this.mileageOnLine,
    required this.mileageOnOrder,
    required this.idleMileage,
  });

  factory CarEfficiencyItem.fromJson(Map<String, dynamic> json) {
    return CarEfficiencyItem(
      car: CarInfo.fromJson(json['car'] as Map<String, dynamic>? ?? {}),
      drivers: (json['drivers'] as List? ?? [])
          .map((e) => DriverInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      dailyStatuses: (json['daily_statuses'] as List? ?? [])
          .map((e) => DailyStatus.fromJson(e as Map<String, dynamic>))
          .toList(),
      successOrdersCount:
          (json['success_orders_count'] as num? ?? 0).toInt(),
      supplyTimeSeconds:
          (json['supply_time_seconds'] as num? ?? 0).toInt(),
      acceptanceRate: (json['acceptance_rate'] as num?)?.toDouble(),
      completionRate: (json['completion_rate'] as num?)?.toDouble(),
      tripsPerHour: (json['trips_per_hour'] as num? ?? 0).toDouble(),
      driverCancellationRate:
          (json['driver_cancellation_rate'] as num?)?.toDouble(),
      mileageOnLine: (json['mileage_on_line'] as num? ?? 0).toDouble(),
      mileageOnOrder: (json['mileage_on_order'] as num? ?? 0).toDouble(),
      idleMileage: (json['idle_mileage'] as num? ?? 0).toDouble(),
    );
  }
}

class CarInfo {
  final String carNumber;
  final String carId;
  final String carBrand;
  final String carModel;

  const CarInfo({
    required this.carNumber,
    required this.carId,
    required this.carBrand,
    required this.carModel,
  });

  factory CarInfo.fromJson(Map<String, dynamic> json) {
    return CarInfo(
      carNumber: json['car_number'] as String? ?? '',
      carId: json['car_id'] as String? ?? '',
      carBrand: json['car_brand'] as String? ?? '',
      carModel: json['car_model'] as String? ?? '',
    );
  }
}

class DriverInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String? middleName;

  const DriverInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      middleName: json['middle_name'] as String?,
    );
  }

  String get fullName {
    final parts = [lastName, firstName].where((s) => s.isNotEmpty);
    return parts.join(' ');
  }
}

class DailyStatus {
  final StatusInfo status;
  final int days;

  const DailyStatus({required this.status, required this.days});

  factory DailyStatus.fromJson(Map<String, dynamic> json) {
    return DailyStatus(
      status: StatusInfo.fromJson(
          json['status'] as Map<String, dynamic>? ?? {}),
      days: (json['days'] as num? ?? 0).toInt(),
    );
  }
}

class StatusInfo {
  final String id;
  final String name;

  const StatusInfo({required this.id, required this.name});

  factory StatusInfo.fromJson(Map<String, dynamic> json) {
    return StatusInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class EfficiencyPagination {
  final int limit;
  final int offset;
  final int total;

  const EfficiencyPagination({
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory EfficiencyPagination.fromJson(Map<String, dynamic> json) {
    return EfficiencyPagination(
      limit: (json['limit'] as num? ?? 0).toInt(),
      offset: (json['offset'] as num? ?? 0).toInt(),
      total: (json['total'] as num? ?? 0).toInt(),
    );
  }
}
