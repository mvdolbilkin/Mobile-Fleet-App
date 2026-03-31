enum StaffStatus { free, busy, onOrder, offline, fired }

class Staff {
  final String id;
  final String name;
  final String initials;
  final StaffStatus status;
  final String timeOnShift;
  final String phoneNumber;
  final String vehicleType;
  final String avatarUrl;

  const Staff({
    required this.id,
    required this.name,
    required this.initials,
    required this.status,
    required this.timeOnShift,
    required this.phoneNumber,
    this.vehicleType = 'Авто',
    this.avatarUrl = '',
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    final profile = json['driver_profile'] ?? {};
    final firstName = profile['first_name'] ?? '';
    final lastName = profile['last_name'] ?? '';
    final middleName = profile['middle_name'] ?? '';
    final id = profile['id'] ?? '';
    final phones = profile['phones'] as List<dynamic>? ?? [];
    final phoneNumber = phones.isNotEmpty ? phones.first.toString() : '';
    
    // Пробуем получить аватар из профиля или используем пустую строку
    final avatarUrl = profile['avatar_url'] ?? profile['avatar_link'] ?? '';
    
    final nameParts = [
      lastName,
      firstName,
      middleName,
    ].where((e) => e.isNotEmpty).toList();
    final fullName = nameParts.join(' ');
    
    String initials = '';
    if (lastName.isNotEmpty) initials += lastName[0];
    if (firstName.isNotEmpty) initials += firstName[0];

    final workStatus = profile['work_status'] ?? '';
    final statusObj = json['current_status'] ?? {};
    final currentStatusStr = statusObj['status'];

    StaffStatus status = StaffStatus.offline;

    // Сначала проверяем рабочий статус (DriverStatus)
    if (workStatus == 'fired' || workStatus == 'not_working') {
       status = StaffStatus.fired;
    } else {
       // Если работает, проверяем текущий статус на линии
       if (currentStatusStr != null) {
          switch (currentStatusStr) {
            case 'free':
              status = StaffStatus.free;
              break;
            case 'busy':
              status = StaffStatus.busy;
              break;
            case 'in_order':
            case 'on_order':
              status = StaffStatus.onOrder;
              break;
            case 'offline':
            default:
              status = StaffStatus.offline;
              break;
          }
       } else {
          // Если current_status отсутствует, но водитель работает
          status = workStatus == 'working' ? StaffStatus.offline : StaffStatus.offline;
       }
    }

    return Staff(
      id: id,
      name: fullName.isEmpty ? 'Неизвестно' : fullName,
      initials: initials.isEmpty ? '?' : initials,
      status: status,
      timeOnShift: '0 ч 0 мин',
      phoneNumber: phoneNumber,
      vehicleType: 'Авто',
      avatarUrl: avatarUrl,
    );
  }
}
