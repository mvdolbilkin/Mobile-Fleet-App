class Vehicle {
  final String id;
  final String plateNumber;
  final String model;
  final String year;
  final String color;
  final VehicleStatus status;
  final int mileage;
  final String? driverName;
  final String? imageUrl;
  
  // Поля из Яндекс API
  final String? brand;
  final String? callsign;
  final String? registrationCert;
  final String? vin;
  final List<String>? amenities;
  final List<String>? categories;
  final List<String>? tariffs;
  final String? transmission;
  final String? bodyNumber;
  final String? fuelType;
  final String? comment;
  final bool? isParkProperty;
  final String? licenseOwnerId;
  final String? ownershipType;
  final String? licenseNumber;

  // Новые поля для фильтрации
  final VehicleType type;
  final VehicleOwner owner;
  final VehicleUsageRight usageRight;
  final VehicleCategory category;

  Vehicle({
    required this.id,
    required this.plateNumber,
    required this.model,
    required this.year,
    required this.color,
    required this.status,
    required this.mileage,
    required this.type,
    required this.owner,
    required this.usageRight,
    required this.category,
    this.driverName,
    this.imageUrl,
    this.brand,
    this.callsign,
    this.registrationCert,
    this.vin,
    this.amenities,
    this.categories,
    this.tariffs,
    this.transmission,
    this.bodyNumber,
    this.fuelType,
    this.comment,
    this.isParkProperty,
    this.licenseOwnerId,
    this.ownershipType,
    this.licenseNumber,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    // status может прийти как объект {id, name} или как строка
    final statusRaw = json['status'];
    final String? statusId = statusRaw is Map
        ? statusRaw['id'] as String?
        : statusRaw as String?;

    return Vehicle(
      id: json['id'] as String? ?? '',
      plateNumber: json['number'] as String? ?? 'Нет номера',
      model: json['model'] as String? ?? 'Неизвестная модель',
      year: json['year']?.toString() ?? 'Неизвестно',
      color: (json['color_name'] ?? json['color']) as String? ?? 'Неизвестно',
      status: _parseStatus(statusId),
      mileage: json['mileage'] as int? ?? 0,
      type: VehicleType.automobile, // По умолчанию
      owner: VehicleOwner.notSpecified, // По умолчанию
      usageRight: VehicleUsageRight.confirmed, // По умолчанию
      category: _parseCategory(json['category'] as List<dynamic>?),
      brand: json['brand'] as String?,
      callsign: json['callsign'] as String?,
      registrationCert: json['registration_cert'] as String?,
      vin: json['vin'] as String?,
      amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      categories: (json['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      tariffs: (json['tariffs'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      transmission: json['transmission'] as String?,
      bodyNumber: json['body_number'] as String?,
      fuelType: json['fuel_type'] as String?,
      comment: json['comment'] as String?,
      isParkProperty: json['is_park_property'] as bool?,
      licenseOwnerId: json['license_owner_id'] as String?,
      ownershipType: json['ownership_type'] as String?,
      licenseNumber: json['licence_number'] as String?,
    );
  }

  static VehicleStatus _parseStatus(String? status) {
    switch (status) {
      case 'working': return VehicleStatus.working;
      case 'not_working': return VehicleStatus.notWorking;
      case 'repairing': return VehicleStatus.service;
      case 'no_driver': return VehicleStatus.noDriver;
      case 'pending': return VehicleStatus.preparation;
      default: return VehicleStatus.other;
    }
  }

  static VehicleCategory _parseCategory(List<dynamic>? categories) {
    if (categories == null || categories.isEmpty) return VehicleCategory.econom;
    final first = categories.first.toString();
    switch (first) {
      case 'comfort': return VehicleCategory.comfort;
      case 'comfort_plus': return VehicleCategory.comfortPlus;
      case 'business': return VehicleCategory.business;
      case 'minivan': return VehicleCategory.minivan;
      case 'vip': return VehicleCategory.vip;
      case 'wagon': return VehicleCategory.wagon;
      case 'pool': return VehicleCategory.pool;
      case 'start': return VehicleCategory.start;
      case 'standart': return VehicleCategory.standart;
      case 'ultimate': return VehicleCategory.ultimate;
      case 'maybach': return VehicleCategory.maybach;
      case 'promo': return VehicleCategory.promo;
      case 'premium_van': return VehicleCategory.premiumVan;
      case 'premium_suv': return VehicleCategory.premiumSuv;
      case 'suv': return VehicleCategory.suv;
      case 'personal_driver': return VehicleCategory.personalDriver;
      case 'express': return VehicleCategory.express;
      case 'cargo': return VehicleCategory.cargo;
      case 'econom':
      default:
        return VehicleCategory.econom;
    }
  }
}

enum VehicleStatus {
  working,
  noDriver,
  service,
  preparation,
  other,
  notWorking,
}

enum VehicleType {
  automobile,
  motorcycle,
  rickshaw,
}

enum VehicleOwner {
  taxiPark,
  other,
  notSpecified,
}

enum VehicleUsageRight {
  confirmed,
  notConfirmed,
}

enum VehicleCategory {
  econom,
  comfort,
  comfortPlus,
  business,
  minivan,
  vip,
  wagon,
  pool,
  start,
  standart,
  ultimate,
  maybach,
  promo,
  premiumVan,
  premiumSuv,
  suv,
  personalDriver,
  express,
  cargo,
}

// Моковые данные
final List<Vehicle> mockVehicles = [
  Vehicle(
    id: '1',
    plateNumber: 'A777AA',
    model: 'AC Ace 2020 Бежевый',
    year: '2020',
    color: 'Бежевый',
    status: VehicleStatus.working,
    mileage: 222222,
    type: VehicleType.automobile,
    owner: VehicleOwner.taxiPark,
    usageRight: VehicleUsageRight.confirmed,
    category: VehicleCategory.business,
    driverName: '1234567890',
  ),
  Vehicle(
    id: '2',
    plateNumber: 'B735OC763',
    model: 'Mahindra (tricycle) Alfa',
    year: '2019',
    color: 'Красный',
    status: VehicleStatus.service,
    mileage: 234214,
    type: VehicleType.rickshaw,
    owner: VehicleOwner.other,
    usageRight: VehicleUsageRight.notConfirmed,
    category: VehicleCategory.econom,
    driverName: '111111111111112',
    imageUrl: 'assets/images/default.jfif',
  ),
  Vehicle(
    id: '3',
    plateNumber: 'XP21277',
    model: 'Acura CL 2017 Белый',
    year: '2017',
    color: 'Белый',
    status: VehicleStatus.noDriver,
    mileage: 1234,
    type: VehicleType.automobile,
    owner: VehicleOwner.taxiPark,
    usageRight: VehicleUsageRight.confirmed,
    category: VehicleCategory.comfort,
    driverName: 'внпп',
  ),
  Vehicle(
    id: '4',
    plateNumber: 'XP36379',
    model: 'Mercedes-Benz E-klasse',
    year: '2021',
    color: 'Черный',
    status: VehicleStatus.preparation,
    mileage: 15000,
    type: VehicleType.automobile,
    owner: VehicleOwner.notSpecified,
    usageRight: VehicleUsageRight.notConfirmed,
    category: VehicleCategory.comfortPlus,
  ),
];
