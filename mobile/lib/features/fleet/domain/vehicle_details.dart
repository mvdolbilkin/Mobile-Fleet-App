class VehicleDetails {
  final ParkProfile? parkProfile;
  final VehicleLicenses? licenses;
  final VehicleSpecifications? specifications;
  final Cargo? cargo;
  final ChildSafety? childSafety;

  VehicleDetails({
    this.parkProfile,
    this.licenses,
    this.specifications,
    this.cargo,
    this.childSafety,
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) {
    return VehicleDetails(
      parkProfile: json['park_profile'] != null
          ? ParkProfile.fromJson(json['park_profile'] as Map<String, dynamic>)
          : null,
      licenses: json['vehicle_licenses'] != null
          ? VehicleLicenses.fromJson(json['vehicle_licenses'] as Map<String, dynamic>)
          : null,
      specifications: json['vehicle_specifications'] != null
          ? VehicleSpecifications.fromJson(json['vehicle_specifications'] as Map<String, dynamic>)
          : null,
      cargo: json['cargo'] != null ? Cargo.fromJson(json['cargo'] as Map<String, dynamic>) : null,
      childSafety: json['child_safety'] != null
          ? ChildSafety.fromJson(json['child_safety'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ParkProfile {
  final String? callsign;
  final String? fuelType;
  final String? status;
  final List<String>? amenities;
  final List<String>? categories;
  final String? comment;
  final bool? isParkProperty;
  final String? licenseOwnerId;
  final String? ownershipType;
  final List<String>? tariffs;
  final LeasingConditions? leasingConditions;

  ParkProfile({
    this.callsign,
    this.fuelType,
    this.status,
    this.amenities,
    this.categories,
    this.comment,
    this.isParkProperty,
    this.licenseOwnerId,
    this.ownershipType,
    this.tariffs,
    this.leasingConditions,
  });

  factory ParkProfile.fromJson(Map<String, dynamic> json) {
    return ParkProfile(
      callsign: json['callsign'] as String?,
      fuelType: json['fuel_type'] as String?,
      status: json['status'] as String?,
      amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      categories: (json['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      comment: json['comment'] as String?,
      isParkProperty: json['is_park_property'] as bool?,
      licenseOwnerId: json['license_owner_id'] as String?,
      ownershipType: json['ownership_type'] as String?,
      tariffs: (json['tariffs'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      leasingConditions: json['leasing_conditions'] != null
          ? LeasingConditions.fromJson(json['leasing_conditions'] as Map<String, dynamic>)
          : null,
    );
  }
}

class VehicleLicenses {
  final String? licencePlateNumber;
  final String? licenceNumber;
  final String? registrationCertificate;

  VehicleLicenses({
    this.licencePlateNumber,
    this.licenceNumber,
    this.registrationCertificate,
  });

  factory VehicleLicenses.fromJson(Map<String, dynamic> json) {
    return VehicleLicenses(
      licencePlateNumber: json['licence_plate_number'] as String?,
      licenceNumber: json['licence_number'] as String?,
      registrationCertificate: json['registration_certificate'] as String?,
    );
  }
}

class VehicleSpecifications {
  final String? brand;
  final String? color;
  final String? model;
  final String? transmission;
  final int? year;
  final String? bodyNumber;
  final int? mileage;
  final String? vin;

  VehicleSpecifications({
    this.brand,
    this.color,
    this.model,
    this.transmission,
    this.year,
    this.bodyNumber,
    this.mileage,
    this.vin,
  });

  factory VehicleSpecifications.fromJson(Map<String, dynamic> json) {
    return VehicleSpecifications(
      brand: json['brand'] as String?,
      color: json['color'] as String?,
      model: json['model'] as String?,
      transmission: json['transmission'] as String?,
      year: json['year'] as int?,
      bodyNumber: json['body_number'] as String?,
      mileage: json['mileage'] as int?,
      vin: json['vin'] as String?,
    );
  }
}

class Cargo {
  final int? cargoLoaders;
  final int? carryingCapacity;
  final Dimensions? cargoHoldDimensions;

  Cargo({
    this.cargoLoaders,
    this.carryingCapacity,
    this.cargoHoldDimensions,
  });

  factory Cargo.fromJson(Map<String, dynamic> json) {
    return Cargo(
      cargoLoaders: json['cargo_loaders'] as int?,
      carryingCapacity: json['carrying_capacity'] as int?,
      cargoHoldDimensions: json['cargo_hold_dimensions'] != null
          ? Dimensions.fromJson(json['cargo_hold_dimensions'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Dimensions {
  final int? height;
  final int? length;
  final int? width;

  Dimensions({
    this.height,
    this.length,
    this.width,
  });

  factory Dimensions.fromJson(Map<String, dynamic> json) {
    return Dimensions(
      height: json['height'] as int?,
      length: json['length'] as int?,
      width: json['width'] as int?,
    );
  }
}

class ChildSafety {
  final int? boosterCount;

  ChildSafety({this.boosterCount});

  factory ChildSafety.fromJson(Map<String, dynamic> json) {
    return ChildSafety(
      boosterCount: json['booster_count'] as int?,
    );
  }
}

class LeasingConditions {
  final String? company;
  final String? interestRate;
  final int? monthlyPayment;
  final String? startDate;
  final int? term;

  LeasingConditions({
    this.company,
    this.interestRate,
    this.monthlyPayment,
    this.startDate,
    this.term,
  });

  factory LeasingConditions.fromJson(Map<String, dynamic> json) {
    return LeasingConditions(
      company: json['company'] as String?,
      interestRate: json['interest_rate'] as String?,
      monthlyPayment: json['monthly_payment'] as int?,
      startDate: json['start_date'] as String?,
      term: json['term'] as int?,
    );
  }
}