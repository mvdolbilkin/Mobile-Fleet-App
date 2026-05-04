class RegularChargeDriver {
  final String id;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? phone;
  final String? balance;
  final String? status;
  final String? workStatus;

  RegularChargeDriver({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.phone,
    this.balance,
    this.status,
    this.workStatus,
  });

  factory RegularChargeDriver.fromJson(Map<String, dynamic> json) {
    return RegularChargeDriver(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      middleName: json['middle_name'] as String?,
      phone: json['phone'] as String?,
      balance: json['balance'] as String?,
      status: json['status'] as String?,
      workStatus: json['work_status'] as String?,
    );
  }

  String get fullName {
    final parts = [lastName, firstName];
    if (middleName != null && middleName!.isNotEmpty) parts.add(middleName!);
    return parts.join(' ');
  }

  String get shortName => '$lastName ${firstName.isNotEmpty ? firstName[0] : ''}.'
      '${middleName != null && middleName!.isNotEmpty ? ' ${middleName![0]}.' : ''}';
}

class RegularChargeCar {
  final String id;
  final String? brand;
  final String? model;
  final String? color;
  final String? year;
  final String? number;
  final String? status;

  RegularChargeCar({
    required this.id,
    this.brand,
    this.model,
    this.color,
    this.year,
    this.number,
    this.status,
  });

  factory RegularChargeCar.fromJson(Map<String, dynamic> json) {
    return RegularChargeCar(
      id: json['id'] as String,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      color: json['color'] as String?,
      year: json['year'] as String?,
      number: json['number'] as String?,
      status: json['status'] as String?,
    );
  }

  String get displayName => '${brand ?? ''} ${model ?? ''}'.trim();
}

class RegularChargeAsset {
  final String type;
  final RegularChargeCar? car;

  RegularChargeAsset({required this.type, this.car});

  factory RegularChargeAsset.fromJson(Map<String, dynamic> json) {
    return RegularChargeAsset(
      type: json['type'] as String,
      car: json['car'] != null
          ? RegularChargeCar.fromJson(json['car'] as Map<String, dynamic>)
          : null,
    );
  }
}

class RegularChargePeriodicity {
  final String type;

  RegularChargePeriodicity({required this.type});

  factory RegularChargePeriodicity.fromJson(Map<String, dynamic> json) {
    return RegularChargePeriodicity(
      type: json['type'] as String,
    );
  }

  String get label {
    switch (type) {
      case 'constant':
        return 'Постоянно';
      case 'daily':
        return 'Ежедневно';
      case 'weekly':
        return 'Еженедельно';
      case 'monthly':
        return 'Ежемесячно';
      default:
        return type;
    }
  }
}

class RegularChargeCharging {
  final String type;
  final String? dailyPrice;
  final RegularChargePeriodicity? periodicity;

  RegularChargeCharging({required this.type, this.dailyPrice, this.periodicity});

  factory RegularChargeCharging.fromJson(Map<String, dynamic> json) {
    return RegularChargeCharging(
      type: json['type'] as String,
      dailyPrice: json['daily_price'] as String?,
      periodicity: json['periodicity'] != null
          ? RegularChargePeriodicity.fromJson(json['periodicity'] as Map<String, dynamic>)
          : null,
    );
  }

  String get typeLabel {
    switch (type) {
      case 'daily':
        return 'Ежедневное';
      case 'weekly':
        return 'Еженедельное';
      case 'monthly':
        return 'Ежемесячное';
      case 'per_shift':
        return 'За смену';
      default:
        return type;
    }
  }
}

class RegularChargeAggregate {
  final String withhold;
  final String withdraw;
  final String cancel;

  RegularChargeAggregate({
    required this.withhold,
    required this.withdraw,
    required this.cancel,
  });

  factory RegularChargeAggregate.fromJson(Map<String, dynamic> json) {
    return RegularChargeAggregate(
      withhold: json['withhold'] as String? ?? '0',
      withdraw: json['withdraw'] as String? ?? '0',
      cancel: json['cancel'] as String? ?? '0',
    );
  }
}

class RegularCharge {
  final String id;
  final String serialId;
  final RegularChargeDriver driver;
  final RegularChargeAsset asset;
  final RegularChargeCharging charging;
  final String dateFrom;
  final String state;
  final String? dateTo;
  final String? chargingAt;
  final String? terminatedAt;
  final RegularChargeAggregate? aggregate;
  final String? comment;
  final String? notificationLimit;

  RegularCharge({
    required this.id,
    required this.serialId,
    required this.driver,
    required this.asset,
    required this.charging,
    required this.dateFrom,
    required this.state,
    this.dateTo,
    this.chargingAt,
    this.terminatedAt,
    this.aggregate,
    this.comment,
    this.notificationLimit,
  });

  factory RegularCharge.fromJson(Map<String, dynamic> json) {
    return RegularCharge(
      id: json['id'] as String,
      serialId: json['serial_id'] as String,
      driver: RegularChargeDriver.fromJson(json['driver'] as Map<String, dynamic>),
      asset: RegularChargeAsset.fromJson(json['asset'] as Map<String, dynamic>),
      charging: RegularChargeCharging.fromJson(json['charging'] as Map<String, dynamic>),
      dateFrom: json['date_from'] as String,
      state: json['state'] as String,
      dateTo: json['date_to'] as String?,
      chargingAt: json['charging_at'] as String?,
      terminatedAt: json['terminated_at'] as String?,
      aggregate: json['aggregate'] != null
          ? RegularChargeAggregate.fromJson(json['aggregate'] as Map<String, dynamic>)
          : null,
      comment: json['comment'] as String?,
      notificationLimit: json['notification_limit'] as String?,
    );
  }
}

class RegularChargesResponse {
  final List<RegularCharge> regularCharges;

  RegularChargesResponse({required this.regularCharges});

  factory RegularChargesResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['regular_charges'] as List?)
            ?.map((e) => RegularCharge.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return RegularChargesResponse(regularCharges: list);
  }
}
