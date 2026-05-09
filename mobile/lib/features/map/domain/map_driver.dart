import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class MapCoordinates {
  final double lon;
  final double lat;

  const MapCoordinates({required this.lon, required this.lat});

  factory MapCoordinates.fromJson(Map<String, dynamic> json) {
    return MapCoordinates(
      lon: (json['lon'] as num).toDouble(),
      lat: (json['lat'] as num).toDouble(),
    );
  }
}

class MapDriverPoint {
  final String driverId;
  final MapCoordinates? coordinates;
  final String status;
  final double balance;
  final int statusDuration;

  const MapDriverPoint({
    required this.driverId,
    this.coordinates,
    required this.status,
    required this.balance,
    required this.statusDuration,
  });

  bool get hasGps => coordinates != null;

  factory MapDriverPoint.fromJson(Map<String, dynamic> json) {
    return MapDriverPoint(
      driverId: json['driver_id'] as String,
      coordinates: json['coordinates'] != null
          ? MapCoordinates.fromJson(json['coordinates'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String? ?? 'busy',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      statusDuration: (json['status_duration'] as num?)?.toInt() ?? 0,
    );
  }
}

class MapTotals {
  final int free;
  final int inOrder;
  final int busy;
  final int noGps;
  final int total;

  const MapTotals({
    required this.free,
    required this.inOrder,
    required this.busy,
    required this.noGps,
    required this.total,
  });

  factory MapTotals.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as Map<String, dynamic>? ?? {};
    return MapTotals(
      free: (status['free'] as num?)?.toInt() ?? 0,
      inOrder: (status['in_order'] as num?)?.toInt() ?? 0,
      busy: (status['busy'] as num?)?.toInt() ?? 0,
      noGps: (json['no_gps'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class MapDriversPointsResponse {
  final List<MapDriverPoint> items;
  final MapTotals totals;

  const MapDriversPointsResponse({required this.items, required this.totals});

  factory MapDriversPointsResponse.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>? ?? [])
        .map((e) => MapDriverPoint.fromJson(e as Map<String, dynamic>))
        .toList();
    final totalsData = json['totals'] as Map<String, dynamic>? ?? {};
    return MapDriversPointsResponse(
      items: itemsList,
      totals: MapTotals.fromJson(totalsData),
    );
  }
}

class MapStatusDuration {
  final int duration;
  final bool isMore;

  const MapStatusDuration({required this.duration, required this.isMore});

  factory MapStatusDuration.fromJson(Map<String, dynamic> json) {
    return MapStatusDuration(
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      isMore: json['is_more'] as bool? ?? false,
    );
  }
}

class MapDriverInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String status;
  final MapStatusDuration statusDuration;
  final String balance;
  final String? avatarUrl;

  const MapDriverInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.status,
    required this.statusDuration,
    required this.balance,
    this.avatarUrl,
  });

  String get fullName {
    final parts = [lastName, firstName];
    if (middleName != null && middleName!.isNotEmpty) {
      parts.add(middleName!);
    }
    return parts.join(' ');
  }

  factory MapDriverInfo.fromJson(Map<String, dynamic> json) {
    return MapDriverInfo(
      id: json['id'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      middleName: json['middle_name'] as String?,
      status: json['status'] as String? ?? 'busy',
      statusDuration: MapStatusDuration.fromJson(
        json['status_duration'] as Map<String, dynamic>? ?? {},
      ),
      balance: json['balance'] as String? ?? '0',
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class MapVehicleInfo {
  final String id;
  final String? brand;
  final String? model;
  final String? number;
  final int? year;

  const MapVehicleInfo({
    required this.id,
    this.brand,
    this.model,
    this.number,
    this.year,
  });

  bool get hasVehicle => number != null && number!.isNotEmpty;

  factory MapVehicleInfo.fromJson(Map<String, dynamic> json) {
    return MapVehicleInfo(
      id: json['id'] as String? ?? '',
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      number: json['number'] as String?,
      year: (json['year'] as num?)?.toInt(),
    );
  }
}

class MapDriverDetail {
  final MapDriverInfo driver;
  final MapVehicleInfo vehicle;

  const MapDriverDetail({required this.driver, required this.vehicle});

  factory MapDriverDetail.fromJson(Map<String, dynamic> json) {
    return MapDriverDetail(
      driver: MapDriverInfo.fromJson(json['driver'] as Map<String, dynamic>),
      vehicle: MapVehicleInfo.fromJson(
        json['vehicle'] as Map<String, dynamic>? ?? {'id': ''},
      ),
    );
  }
}

class MapDriversListResponse {
  final List<MapDriverDetail> items;

  const MapDriversListResponse({required this.items});

  factory MapDriversListResponse.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>? ?? [])
        .map((e) => MapDriverDetail.fromJson(e as Map<String, dynamic>))
        .toList();
    return MapDriversListResponse(items: itemsList);
  }
}

class MapCombinedDriver {
  final String id;
  final String fullName;
  final String status;
  final bool hasGps;
  final int statusDurationSeconds;
  final bool statusDurationIsMore;
  final double balance;
  final String? vehicleNumber;
  final String? avatarUrl;

  const MapCombinedDriver({
    required this.id,
    required this.fullName,
    required this.status,
    required this.hasGps,
    required this.statusDurationSeconds,
    required this.statusDurationIsMore,
    required this.balance,
    this.vehicleNumber,
    this.avatarUrl,
  });

  String get statusLabel {
    switch (status) {
      case 'free':
        return 'Свободен';
      case 'in_order':
        return 'На заказе';
      case 'busy':
      default:
        return 'Занят';
    }
  }

  String get statusDurationLabel {
    final totalSeconds = statusDurationSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '$statusLabel $hours ч ${minutes.toString().padLeft(2, '0')} мин';
    }
    return '$statusLabel $minutes мин';
  }

  String get balanceFormatted {
    final formatted = balance.toStringAsFixed(2).replaceAll('.', ',');
    return '$formatted ₽';
  }

  factory MapCombinedDriver.fromDriverDetail(MapDriverDetail detail) {
    return MapCombinedDriver(
      id: detail.driver.id,
      fullName: detail.driver.fullName,
      status: detail.driver.status,
      hasGps: false,
      statusDurationSeconds: detail.driver.statusDuration.duration,
      statusDurationIsMore: detail.driver.statusDuration.isMore,
      balance: double.tryParse(detail.driver.balance) ?? 0.0,
      vehicleNumber: detail.vehicle.hasVehicle ? detail.vehicle.number : null,
      avatarUrl: detail.driver.avatarUrl,
    );
  }
}

// WorkRule

class WorkRule {
  final String id;
  final String name;
  final String commissionPercent;

  const WorkRule({
    required this.id,
    required this.name,
    required this.commissionPercent,
  });

  factory WorkRule.fromJson(Map<String, dynamic> json) {
    final commission =
        (json['default_commission'] as Map<String, dynamic>?)?['percent']
            as String? ??
        '0';
    return WorkRule(
      id: json['id'] as String,
      name: json['name'] as String,
      commissionPercent: commission,
    );
  }
}

// MapFilterState

class MapFilterState {
  final List<String> paymentMethods;
  final List<String> workRuleIds;
  final List<String> carCategories;
  final String sortField;
  final String sortDirection;

  const MapFilterState({
    this.paymentMethods = const [],
    this.workRuleIds = const [],
    this.carCategories = const [],
    this.sortField = 'status_duration',
    this.sortDirection = 'desc',
  });

  bool get hasServerFilters =>
      paymentMethods.isNotEmpty ||
      workRuleIds.isNotEmpty ||
      carCategories.isNotEmpty;

  int get activeFilterCount =>
      (paymentMethods.isNotEmpty ? 1 : 0) +
      (workRuleIds.isNotEmpty ? 1 : 0) +
      (carCategories.isNotEmpty ? 1 : 0);

  Map<String, dynamic> toServerBody() {
    final body = <String, dynamic>{};
    if (paymentMethods.isNotEmpty) body['payment_methods'] = paymentMethods;
    if (workRuleIds.isNotEmpty) body['work_rule_ids'] = workRuleIds;
    if (carCategories.isNotEmpty) body['car'] = {'categories': carCategories};
    body['sort'] = {'field': sortField, 'direction': sortDirection};
    return body;
  }

  MapFilterState copyWith({
    List<String>? paymentMethods,
    List<String>? workRuleIds,
    List<String>? carCategories,
    String? sortField,
    String? sortDirection,
  }) {
    return MapFilterState(
      paymentMethods: paymentMethods ?? this.paymentMethods,
      workRuleIds: workRuleIds ?? this.workRuleIds,
      carCategories: carCategories ?? this.carCategories,
      sortField: sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }
}

class MapFilterNotifier extends StateNotifier<MapFilterState> {
  MapFilterNotifier() : super(const MapFilterState());
  void update(MapFilterState newState) => state = newState;
  void reset() => state = const MapFilterState();
}


// Driver item (detailed)

class MapDriverItemDriver {
  final String id;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String status;
  final int statusDurationSeconds;
  final bool statusDurationIsMore;
  final String phone;
  final String license;
  final double balance;
  final String? avatarUrl;

  const MapDriverItemDriver({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.status,
    required this.statusDurationSeconds,
    required this.statusDurationIsMore,
    required this.phone,
    required this.license,
    required this.balance,
    this.avatarUrl,
  });

  String get fullName {
    final parts = [lastName, firstName];
    if (middleName != null && middleName!.isNotEmpty) parts.add(middleName!);
    return parts.where((p) => p.isNotEmpty).join(' ');
  }

  String get statusLabel {
    switch (status) {
      case 'free':
        return 'Свободен';
      case 'in_order':
        return 'На заказе';
      case 'busy':
      default:
        return 'Занят';
    }
  }

  String get statusDurationLabel {
    final hours = statusDurationSeconds ~/ 3600;
    final minutes = (statusDurationSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '$statusLabel $hours ч ${minutes.toString().padLeft(2, '0')} мин';
    }
    return '$statusLabel $minutes мин';
  }

  String get balanceFormatted {
    final val = balance.toStringAsFixed(2);
    final parts = val.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    return '$intPart,${parts[1]} ₽';
  }

  factory MapDriverItemDriver.fromJson(Map<String, dynamic> json) {
    final sd = json['status_duration'] as Map<String, dynamic>? ?? {};
    return MapDriverItemDriver(
      id: json['id'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      middleName: json['middle_name'] as String?,
      status: json['status'] as String? ?? 'busy',
      statusDurationSeconds: (sd['duration'] as num?)?.toInt() ?? 0,
      statusDurationIsMore: sd['is_more'] as bool? ?? false,
      phone: json['phone'] as String? ?? '',
      license: json['license'] as String? ?? '',
      balance: double.tryParse(json['balance'] as String? ?? '0') ?? 0.0,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class MapDriverItemResponse {
  final MapCoordinates? coordinates;
  final MapDriverItemDriver driver;
  final MapVehicleInfo? vehicle;

  const MapDriverItemResponse({
    this.coordinates,
    required this.driver,
    this.vehicle,
  });

  factory MapDriverItemResponse.fromJson(Map<String, dynamic> json) {
    return MapDriverItemResponse(
      coordinates: json['coordinates'] != null
          ? MapCoordinates.fromJson(
              json['coordinates'] as Map<String, dynamic>)
          : null,
      driver: MapDriverItemDriver.fromJson(
          json['driver'] as Map<String, dynamic>),
      vehicle: json['vehicle'] != null
          ? MapVehicleInfo.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
    );
  }
}

// Status history

class MapStatusHistoryItem {
  final String status;
  final DateTime date;

  const MapStatusHistoryItem({required this.status, required this.date});

  String get statusLabel {
    switch (status) {
      case 'free':
        return 'Свободен';
      case 'in_order':
        return 'На заказе';
      case 'busy':
        return 'Занят';
      case 'offline':
        return 'Офлайн';
      default:
        return status;
    }
  }

  String get timeLabel {
    final local = date.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  factory MapStatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return MapStatusHistoryItem(
      status: json['status'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class MapDriverStatusHistoryResponse {
  final List<MapStatusHistoryItem> items;

  const MapDriverStatusHistoryResponse({required this.items});

  factory MapDriverStatusHistoryResponse.fromJson(Map<String, dynamic> json) {
    return MapDriverStatusHistoryResponse(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => MapStatusHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// MapCombinedData

class MapCombinedData {
  final MapDriversPointsResponse points;
  final MapDriversListResponse details;

  const MapCombinedData({required this.points, required this.details});

  List<MapCombinedDriver> get combinedDrivers {
    final pointsMap = {for (final p in points.items) p.driverId: p};
    return details.items.map((item) {
      final point = pointsMap[item.driver.id];
      return MapCombinedDriver(
        id: item.driver.id,
        fullName: item.driver.fullName,
        status: item.driver.status,
        hasGps: point?.hasGps ?? false,
        statusDurationSeconds: item.driver.statusDuration.duration,
        statusDurationIsMore: item.driver.statusDuration.isMore,
        balance: double.tryParse(item.driver.balance) ?? 0.0,
        vehicleNumber: item.vehicle.hasVehicle ? item.vehicle.number : null,
        avatarUrl: item.driver.avatarUrl,
      );
    }).toList();
  }
}

// Surge

class SurgeFeature {
  final double lat;
  final double lon;
  final double surge;
  final double surgeRaw;

  const SurgeFeature({
    required this.lat,
    required this.lon,
    required this.surge,
    required this.surgeRaw,
  });

  factory SurgeFeature.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] as List<dynamic>;
    return SurgeFeature(
      lon: (coords[0] as num).toDouble(),
      lat: (coords[1] as num).toDouble(),
      surge: (json['surge'] as num).toDouble(),
      surgeRaw: (json['surge_raw'] as num? ?? 1.0).toDouble(),
    );
  }
}

class SurgeResponse {
  final double legendMin;
  final double legendMax;
  final String legend;
  final List<SurgeFeature> features;

  const SurgeResponse({
    required this.legendMin,
    required this.legendMax,
    required this.legend,
    required this.features,
  });

  factory SurgeResponse.fromJson(Map<String, dynamic> json) {
    return SurgeResponse(
      legendMin: (json['legend_min'] as num).toDouble(),
      legendMax: (json['legend_max'] as num).toDouble(),
      legend: json['legend'] as String,
      features: (json['surge_features'] as List<dynamic>? ?? [])
          .map((e) => SurgeFeature.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
