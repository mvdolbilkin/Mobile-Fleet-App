class VehicleEfficiency {
  final int inactiveDays;
  final int supplyTimeSeconds;
  final int successOrdersCount;
  final double summaryIncome;

  const VehicleEfficiency({
    required this.inactiveDays,
    required this.supplyTimeSeconds,
    required this.successOrdersCount,
    required this.summaryIncome,
  });

  factory VehicleEfficiency.fromJson(Map<String, dynamic> json) {
    return VehicleEfficiency(
      inactiveDays: (json['inactive_days'] as num?)?.toInt() ?? 0,
      supplyTimeSeconds: (json['supply_time_seconds'] as num?)?.toInt() ?? 0,
      successOrdersCount: (json['success_orders_count'] as num?)?.toInt() ?? 0,
      summaryIncome: (json['summary_income'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get supplyTimeFormatted {
    final h = supplyTimeSeconds ~/ 3600;
    final m = (supplyTimeSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}ч ${m}м';
    if (m > 0) return '${m}м';
    return '0м';
  }

  String get incomeFormatted {
    if (summaryIncome == 0) return '0 ₽';
    final parts = summaryIncome.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    return '$intPart ₽';
  }
}

class EfficiencyParams {
  final String vehicleId;
  final String dateFrom;
  final String dateTo;

  const EfficiencyParams({
    required this.vehicleId,
    required this.dateFrom,
    required this.dateTo,
  });

  @override
  bool operator ==(Object other) =>
      other is EfficiencyParams &&
      other.vehicleId == vehicleId &&
      other.dateFrom == dateFrom &&
      other.dateTo == dateTo;

  @override
  int get hashCode => Object.hash(vehicleId, dateFrom, dateTo);
}

class VehicleBranding {
  final bool sticker;
  final bool lightbox;
  final bool digitalLightbox;
  final bool stickerConfirmed;
  final bool lightboxConfirmed;
  final bool digitalLightboxConfirmed;

  const VehicleBranding({
    required this.sticker,
    required this.lightbox,
    required this.digitalLightbox,
    required this.stickerConfirmed,
    required this.lightboxConfirmed,
    required this.digitalLightboxConfirmed,
  });

  factory VehicleBranding.fromJson(Map<String, dynamic> json) {
    return VehicleBranding(
      sticker: json['sticker'] as bool? ?? false,
      lightbox: json['lightbox'] as bool? ?? false,
      digitalLightbox: json['digital_lightbox'] as bool? ?? false,
      stickerConfirmed: json['sticker_confirmed'] as bool? ?? false,
      lightboxConfirmed: json['lightbox_confirmed'] as bool? ?? false,
      digitalLightboxConfirmed:
          json['digital_lightbox_confirmed'] as bool? ?? false,
    );
  }
}

class ChildChair {
  final String id;
  final String parkId;
  final String entityId;
  final List<int> categories;
  final String qcStatus;
  final String owner;
  final bool enabled;

  const ChildChair({
    required this.id,
    required this.parkId,
    required this.entityId,
    required this.categories,
    required this.qcStatus,
    required this.owner,
    required this.enabled,
  });

  factory ChildChair.fromJson(Map<String, dynamic> json) {
    return ChildChair(
      id: json['id'] as String? ?? '',
      parkId: json['park_id'] as String? ?? '',
      entityId: json['entity_id'] as String? ?? '',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      qcStatus: json['qc_status'] as String? ?? '',
      owner: json['owner'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? false,
    );
  }

  String get qcStatusLabel {
    switch (qcStatus) {
      case 'overdue':
        return 'Фотоконтроль просрочен';
      case 'ok':
        return 'Фотоконтроль пройден';
      case 'pending':
        return 'Ожидаем фотоконтроль';
      default:
        return qcStatus;
    }
  }

  String get categoriesLabel => categories.join(', ');
}

// VehicleKeyInfo

class VehicleOwnershipExam {
  final String state;
  final String title;
  final String description;

  const VehicleOwnershipExam({
    required this.state,
    required this.title,
    required this.description,
  });

  factory VehicleOwnershipExam.fromJson(Map<String, dynamic> json) {
    return VehicleOwnershipExam(
      state: json['state'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  List<String> get descriptionLines {
    return description
        .split('\n')
        .map((l) => l.replaceAll(RegExp(r'^\s*-\s*'), '').trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }
}

class VehicleKeyInfoBadges {
  final String vehicleOwnerType;
  final int driversTotal;
  final String branding;
  final bool isOwnershipConfirmed;
  final VehicleOwnershipExam? ownershipExam;

  const VehicleKeyInfoBadges({
    required this.vehicleOwnerType,
    required this.driversTotal,
    required this.branding,
    required this.isOwnershipConfirmed,
    this.ownershipExam,
  });

  factory VehicleKeyInfoBadges.fromJson(Map<String, dynamic> json) {
    return VehicleKeyInfoBadges(
      vehicleOwnerType: json['vehicle_owner_type'] as String? ?? '',
      driversTotal: (json['drivers_total'] as num?)?.toInt() ?? 0,
      branding: json['branding'] as String? ?? '',
      isOwnershipConfirmed: json['is_ownership_confirmed'] as bool? ?? false,
      ownershipExam: json['ownership_exam'] != null
          ? VehicleOwnershipExam.fromJson(
              json['ownership_exam'] as Map<String, dynamic>)
          : null,
    );
  }
}

class VehicleKeyInfo {
  final String brand;
  final String model;
  final int year;
  final String number;
  final String status;
  final String vehicleType;
  final String vehicleOwnerType;
  final VehicleKeyInfoBadges badges;
  final bool isReadonly;

  const VehicleKeyInfo({
    required this.brand,
    required this.model,
    required this.year,
    required this.number,
    required this.status,
    required this.vehicleType,
    required this.vehicleOwnerType,
    required this.badges,
    required this.isReadonly,
  });

  factory VehicleKeyInfo.fromJson(Map<String, dynamic> json) {
    return VehicleKeyInfo(
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      number: json['number'] as String? ?? '',
      status: json['status'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String? ?? '',
      vehicleOwnerType: json['vehicle_owner_type'] as String? ?? '',
      badges: VehicleKeyInfoBadges.fromJson(
          json['badges'] as Map<String, dynamic>? ?? {}),
      isReadonly: json['is_readonly'] as bool? ?? false,
    );
  }

  String get ownerTypeLabel {
    switch (vehicleOwnerType) {
      case 'park':
        return 'Парковый автомобиль';
      case 'contractor':
        return 'Автомобиль водителя';
      default:
        return vehicleOwnerType;
    }
  }
}

// VehicleChangelog

class ChangeValue {
  final String fieldId;
  final String fieldName;
  final String oldValue;
  final String newValue;

  const ChangeValue({
    required this.fieldId,
    required this.fieldName,
    required this.oldValue,
    required this.newValue,
  });

  factory ChangeValue.fromJson(Map<String, dynamic> json) {
    return ChangeValue(
      fieldId: json['field_id'] as String? ?? '',
      fieldName: json['field_name'] as String? ?? '',
      oldValue: json['old'] as String? ?? '',
      newValue: json['new'] as String? ?? '',
    );
  }
}

class ChangeAuthor {
  final String name;

  const ChangeAuthor({required this.name});

  factory ChangeAuthor.fromJson(Map<String, dynamic> json) {
    return ChangeAuthor(name: json['name'] as String? ?? '');
  }
}

class VehicleChange {
  final String createdAt;
  final ChangeAuthor author;
  final List<ChangeValue> values;

  const VehicleChange({
    required this.createdAt,
    required this.author,
    required this.values,
  });

  factory VehicleChange.fromJson(Map<String, dynamic> json) {
    return VehicleChange(
      createdAt: json['created_at'] as String? ?? '',
      author: ChangeAuthor.fromJson(
          json['author'] as Map<String, dynamic>? ?? {}),
      values: (json['values'] as List<dynamic>?)
              ?.map((e) => ChangeValue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String get formattedDate {
    try {
      final dt =
          DateTime.parse(createdAt).toUtc().add(const Duration(hours: 3));
      const months = [
        '', 'янв', 'фев', 'мар', 'апр', 'мая', 'июн',
        'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
      ];
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month]}, $h:$m';
    } catch (_) {
      return createdAt;
    }
  }

  String get headerTitle {
    if (values.isEmpty) return '';
    final names = values.map((v) => v.fieldName).toSet().join(', ');
    return names;
  }
}

class VehicleChangelogResponse {
  final List<VehicleChange> changes;
  final String? cursor;

  const VehicleChangelogResponse({required this.changes, this.cursor});

  factory VehicleChangelogResponse.fromJson(Map<String, dynamic> json) {
    return VehicleChangelogResponse(
      changes: (json['changes'] as List<dynamic>?)
              ?.map((e) => VehicleChange.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cursor: json['cursor'] as String?,
    );
  }
}

// VehicleStatusExtras

class VehicleStatusExtras {
  final bool supplyLockActive;
  final bool isPolicyRequired;
  final bool parkCompensationEnabled;
  final bool parkCompensationReadonly;

  const VehicleStatusExtras({
    required this.supplyLockActive,
    required this.isPolicyRequired,
    required this.parkCompensationEnabled,
    required this.parkCompensationReadonly,
  });
}

class ChildChairsResponse {
  final List<ChildChair> parkChairs;
  final List<ChildChair> contractorsChairs;

  const ChildChairsResponse({
    required this.parkChairs,
    required this.contractorsChairs,
  });

  List<ChildChair> get all => [...parkChairs, ...contractorsChairs];

  factory ChildChairsResponse.fromJson(Map<String, dynamic> json) {
    return ChildChairsResponse(
      parkChairs: (json['park_chairs'] as List<dynamic>?)
              ?.map((e) => ChildChair.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      contractorsChairs: (json['contractors_chairs'] as List<dynamic>?)
              ?.map((e) => ChildChair.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
