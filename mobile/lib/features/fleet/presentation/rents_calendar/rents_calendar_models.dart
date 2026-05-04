class RentDriver {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? balance;

  RentDriver({
    required this.id,
    this.firstName,
    this.lastName,
    this.middleName,
    this.balance,
  });

  factory RentDriver.fromJson(Map<String, dynamic> json) {
    return RentDriver(
      id: json['id'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      middleName: json['middle_name'] as String?,
      balance: json['balance'] as String?,
    );
  }
}

class RentInfo {
  final String id;
  final String driverId;
  final String? dailyPrice;
  final String debitTime;

  RentInfo({
    required this.id,
    required this.driverId,
    this.dailyPrice,
    required this.debitTime,
  });

  bool get isDayOff => dailyPrice == null;

  factory RentInfo.fromJson(Map<String, dynamic> json) {
    return RentInfo(
      id: json['id'] as String,
      driverId: json['driver_id'] as String,
      dailyPrice: json['daily_price'] as String?,
      debitTime: json['debit_time'] as String,
    );
  }
}

class VehicleRentDataDay {
  final List<RentInfo> rents;

  VehicleRentDataDay({
    required this.rents,
  });

  factory VehicleRentDataDay.fromJson(Map<String, dynamic> json) {
    final rentsJson = json['rents'] as List<dynamic>? ?? [];
    return VehicleRentDataDay(
      rents: rentsJson.map((e) => RentInfo.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class VehicleWithRents {
  final String id;
  final String? brand;
  final String? model;
  final String? number;
  final String? status;
  final List<VehicleRentDataDay> dataByDay;

  VehicleWithRents({
    required this.id,
    this.brand,
    this.model,
    this.number,
    this.status,
    required this.dataByDay,
  });

  factory VehicleWithRents.fromJson(Map<String, dynamic> json) {
    final dataByDayJson = json['data_by_day'] as List<dynamic>? ?? [];
    return VehicleWithRents(
      id: json['id'] as String,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      number: json['number'] as String?,
      status: json['status'] as String?,
      dataByDay: dataByDayJson.map((e) => VehicleRentDataDay.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class DriverBalanceItem {
  final String date;
  final double balance;

  DriverBalanceItem({required this.date, required this.balance});

  factory DriverBalanceItem.fromJson(Map<String, dynamic> json) {
    return DriverBalanceItem(
      date: json['date'] as String,
      balance: (json['balance'] as num).toDouble(),
    );
  }
}

class DriverBalanceHistoryResponse {
  final List<DriverBalanceItem> balances;
  final int total;
  final int pageSize;

  DriverBalanceHistoryResponse({
    required this.balances,
    required this.total,
    required this.pageSize,
  });

  factory DriverBalanceHistoryResponse.fromJson(Map<String, dynamic> json) {
    final balancesJson = json['balances'] as List<dynamic>? ?? [];
    return DriverBalanceHistoryResponse(
      balances: balancesJson
          .map((e) => DriverBalanceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      pageSize: json['page_size'] as int? ?? 25,
    );
  }
}

class RentsCalendarResponse {
  final List<VehicleWithRents> vehicles;
  final int total;
  final List<RentDriver> drivers;

  RentsCalendarResponse({
    required this.vehicles,
    required this.total,
    required this.drivers,
  });

  factory RentsCalendarResponse.fromJson(Map<String, dynamic> json) {
    final vehiclesJson = json['vehicles'] as List<dynamic>? ?? [];
    final driversJson = json['drivers'] as List<dynamic>? ?? [];
    return RentsCalendarResponse(
      vehicles: vehiclesJson.map((e) => VehicleWithRents.fromJson(e as Map<String, dynamic>)).toList(),
      total: json['total'] as int? ?? 0,
      drivers: driversJson.map((e) => RentDriver.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
