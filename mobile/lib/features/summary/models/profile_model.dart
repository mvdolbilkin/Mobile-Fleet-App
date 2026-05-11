class ProfileResponse {
  final ParkProfile park;

  ProfileResponse({required this.park});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      park: ParkProfile.fromJson(json['park']),
    );
  }
}

class ParkProfile {
  final String id;
  final String name;
  final String clid;
  final String timezone;
  final int timezoneOffset;
  final City city;

  ParkProfile({
    required this.id,
    required this.name,
    required this.clid,
    required this.timezone,
    required this.timezoneOffset,
    required this.city,
  });

  factory ParkProfile.fromJson(Map<String, dynamic> json) {
    return ParkProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      clid: json['clid'] ?? '',
      timezone: json['timezone'] ?? '',
      timezoneOffset: json['timezone_offset'] ?? 0,
      city: json['city'] != null ? City.fromJson(json['city']) : City(name: ''),
    );
  }
}

class City {
  final String name;

  City({required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] ?? '',
    );
  }
}
