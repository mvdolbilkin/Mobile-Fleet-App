enum StaffStatus {
  free,
  working, // Matches "Работает" from Figma
  busy,
  onOrder,
  offline,
}

class Staff {
  final String id;
  final String name;
  final String initials;
  final StaffStatus status;
  final String timeOnShift;
  final String phoneNumber;

  const Staff({
    required this.id,
    required this.name,
    required this.initials,
    required this.status,
    required this.timeOnShift,
    required this.phoneNumber,
  });
}
