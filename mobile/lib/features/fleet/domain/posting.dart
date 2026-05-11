class PostingOffice {
  final String officeId;
  final String address;

  const PostingOffice({required this.officeId, required this.address});

  factory PostingOffice.fromJson(Map<String, dynamic> json) {
    return PostingOffice(
      officeId: json['office_id'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }
}

class PostingLabelValue {
  final String value;
  final String label;

  const PostingLabelValue({required this.value, required this.label});

  factory PostingLabelValue.fromJson(Map<String, dynamic> json) {
    return PostingLabelValue(
      value: json['value'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}

class PostingVehicleInfo {
  final int total;
  final int postedCount;

  const PostingVehicleInfo({required this.total, required this.postedCount});

  factory PostingVehicleInfo.fromJson(Map<String, dynamic> json) {
    return PostingVehicleInfo(
      total: json['total'] as int? ?? 0,
      postedCount: json['posted_count'] as int? ?? 0,
    );
  }
}

class Posting {
  final String postingId;
  final String parkId;
  final String brand;
  final String model;
  final int year;
  final PostingLabelValue fuelType;
  final PostingLabelValue transmission;
  final PostingOffice office;
  final String status;
  final PostingVehicleInfo vehicleInfo;
  final List<String> images;

  const Posting({
    required this.postingId,
    required this.parkId,
    required this.brand,
    required this.model,
    required this.year,
    required this.fuelType,
    required this.transmission,
    required this.office,
    required this.status,
    required this.vehicleInfo,
    required this.images,
  });

  String get title => '$brand $model $year';

  String get availabilityText =>
      '${vehicleInfo.postedCount} свободно из ${vehicleInfo.total}';

  String get statusLabel {
    switch (status) {
      case 'without_rent_rule':
        return 'Укажите условия аренды';
      case 'posted':
        return 'Опубликовано в Гараже';
      case 'not_posted':
        return 'Не опубликовано';
      default:
        return status;
    }
  }

  bool get isPublished => status == 'posted';

  factory Posting.fromJson(Map<String, dynamic> json) {
    return Posting(
      postingId: json['posting_id'] as String? ?? '',
      parkId: json['park_id'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      fuelType: PostingLabelValue.fromJson(
        json['fuel_type'] as Map<String, dynamic>? ?? {},
      ),
      transmission: PostingLabelValue.fromJson(
        json['transmission'] as Map<String, dynamic>? ?? {},
      ),
      office: PostingOffice.fromJson(
        json['office'] as Map<String, dynamic>? ?? {},
      ),
      status: json['status'] as String? ?? '',
      vehicleInfo: PostingVehicleInfo.fromJson(
        json['vehicle_info'] as Map<String, dynamic>? ?? {},
      ),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
