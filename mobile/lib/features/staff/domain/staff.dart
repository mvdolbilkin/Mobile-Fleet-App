enum StaffStatus { free, busy, onOrder, offline, fired }

class Staff {
  Staff copyWith({
    String? id,
    String? name,
    String? initials,
    StaffStatus? status,
    String? timeOnShift,
    String? phoneNumber,
    String? vehicleType,
    String? avatarUrl,
    String? balance,
    String? email,
    String? address,
    String? taxNumber,
    String? employmentType,
    String? comment,
    String? balanceLimit,
    String? hireDate,
    String? carId,
    String? driverLicenseNumber,
    String? driverLicenseIssueDate,
    String? driverLicenseExpiryDate,
    String? driverLicenseCountry,
  }) {
    return Staff(
      id: id ?? this.id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      status: status ?? this.status,
      timeOnShift: timeOnShift ?? this.timeOnShift,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      balance: balance ?? this.balance,
      email: email ?? this.email,
      address: address ?? this.address,
      taxNumber: taxNumber ?? this.taxNumber,
      employmentType: employmentType ?? this.employmentType,
      comment: comment ?? this.comment,
      balanceLimit: balanceLimit ?? this.balanceLimit,
      hireDate: hireDate ?? this.hireDate,
      carId: carId ?? this.carId,
      driverLicenseNumber: driverLicenseNumber ?? this.driverLicenseNumber,
      driverLicenseIssueDate: driverLicenseIssueDate ?? this.driverLicenseIssueDate,
      driverLicenseExpiryDate: driverLicenseExpiryDate ?? this.driverLicenseExpiryDate,
      driverLicenseCountry: driverLicenseCountry ?? this.driverLicenseCountry,
    );
  }
  final String id;
  final String name;
  final String initials;
  final StaffStatus status;
  final String timeOnShift;
  final String phoneNumber;
  final String vehicleType;
  final String avatarUrl;
  final String balance;

  // Новые поля из V2 API
  final String email;
  final String address;
  final String taxNumber;
  final String employmentType;
  final String comment;
  final String balanceLimit;
  final String hireDate;
  final String carId;
  final String driverLicenseNumber;
  final String driverLicenseIssueDate;
  final String driverLicenseExpiryDate;
  final String driverLicenseCountry;

  // Кэшированные поля для быстрого поиска и сортировки, чтобы не грузить UI-поток
  final String searchName;
  final String searchPhone;

  Staff({
    required this.id,
    required this.name,
    required this.initials,
    required this.status,
    required this.timeOnShift,
    required this.phoneNumber,
    this.vehicleType = 'Авто',
    this.avatarUrl = '',
    this.balance = '0 ₽',
    this.email = '',
    this.address = '',
    this.taxNumber = '',
    this.employmentType = '',
    this.comment = '',
    this.balanceLimit = '',
    this.hireDate = '',
    this.carId = '',
    this.driverLicenseNumber = '',
    this.driverLicenseIssueDate = '',
    this.driverLicenseExpiryDate = '',
    this.driverLicenseCountry = '',
  }) : searchName = name.toLowerCase(),
       searchPhone = phoneNumber.toLowerCase();

  factory Staff.fromContractorJson(Map<String, dynamic> json) {
    final id = json['id'] ?? '';
    final fullName = json['full_name']?.toString() ?? 'Неизвестно';
    final phoneVal = json['phone']?.toString() ?? '';
    final balance = json['balance']?.toString() ?? '0';
    final avatarUrl = json['avatar_url']?.toString() ?? '';
    
    // Статус водителя (offline, free, busy и т.д.)
    final statusStr = json['status']?.toString() ?? 'offline';
    StaffStatus status = StaffStatus.offline;
    switch (statusStr) {
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
      default:
        status = StaffStatus.offline;
        break;
    }

    String initials = '?';
    if (fullName.isNotEmpty && fullName != 'Неизвестно') {
      final nameParts = fullName.split(' ').where((part) => part.trim().isNotEmpty).toList();
      if (nameParts.length >= 2) {
        initials = '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      } else if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
        initials = nameParts[0][0].toUpperCase();
      }
    }

    return Staff(
      id: id,
      name: fullName,
      initials: initials,
      status: status,
      timeOnShift: '0 ч 0 мин',
      phoneNumber: phoneVal,
      vehicleType: 'Авто', // по умолчанию, или можно добавить логику
      avatarUrl: avatarUrl,
      balance: '$balance ₽',
    );
  }

  factory Staff.fromUserJson(Map<String, dynamic> json) {
    final id = json['user_id'] ?? '';
    final nameVal = json['name']?.toString() ?? '';
    final login = json['login']?.toString() ?? '';
    final emailVal = json['email']?.toString() ?? '';
    final phoneVal = json['phone']?.toString() ?? '';
    final isEnabled = json['is_enabled'] == true;

    final displayName = nameVal.isNotEmpty ? nameVal : (login.isNotEmpty ? login : 'Неизвестно');
    
    String initials = '?';
    if (displayName.isNotEmpty && displayName != 'Неизвестно') {
      initials = displayName[0].toUpperCase();
    }

    final status = isEnabled ? StaffStatus.offline : StaffStatus.fired; // Используем offline как дефолт для включенных

    return Staff(
      id: id,
      name: displayName,
      initials: initials,
      status: status,
      timeOnShift: '0 ч 0 мин',
      phoneNumber: phoneVal,
      email: emailVal,
      vehicleType: 'Авто',
      avatarUrl: '',
      balance: '0 ₽',
    );
  }

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
        status = workStatus == 'working'
            ? StaffStatus.offline
            : StaffStatus.offline;
      }
    }

    final accounts = json['accounts'] as List<dynamic>? ?? [];
    String balanceVal = '0 ₽';
    if (accounts.isNotEmpty) {
      final acc = accounts.first;
      // Если API Яндекса вернет balance:
      if (acc['balance'] != null) {
        final balStr = acc['balance'].toString();
        final balDouble = double.tryParse(balStr);
        if (balDouble != null) {
          if (balDouble.truncateToDouble() == balDouble) {
            balanceVal = '${balDouble.toInt()} ₽';
          } else {
            balanceVal = '${balDouble.toStringAsFixed(2)} ₽';
          }
        } else {
          balanceVal = '$balStr ₽';
        }
      }
    }

    final finalName = fullName.isEmpty ? 'Неизвестно' : fullName;

    return Staff(
      id: id,
      name: finalName,
      initials: initials.isEmpty ? '?' : initials,
      status: status,
      timeOnShift: '0 ч 0 мин',
      phoneNumber: phoneNumber,
      vehicleType: 'Авто',
      avatarUrl: avatarUrl,
      balance: balanceVal,
    );
  }

  factory Staff.fromV2ProfileJson(String profileId, Map<String, dynamic> json) {
    final person = json['person'] ?? {};
    final fullName = person['full_name'] ?? {};
    final firstName = fullName['first_name'] ?? '';
    final lastName = fullName['last_name'] ?? '';
    final middleName = fullName['middle_name'] ?? '';
    
    final nameParts = [lastName, firstName, middleName].where((e) => e.toString().isNotEmpty).toList();
    final name = nameParts.join(' ');
    
    String initials = '';
    if (lastName.toString().isNotEmpty) initials += lastName.toString()[0];
    if (firstName.toString().isNotEmpty) initials += firstName.toString()[0];

    final contactInfo = person['contact_info'] ?? {};
    final phone = contactInfo['phone'] ?? '';
    final email = contactInfo['email'] ?? '';
    final address = contactInfo['address'] ?? '';

    final taxNumber = person['tax_identification_number'] ?? '';
    final employmentTypeStr = person['employment_type'] ?? '';

    final driverLicense = person['driver_license'] ?? {};
    final dlNumber = driverLicense['number'] ?? '';
    final dlIssue = driverLicense['issue_date'] ?? '';
    final dlExpiry = driverLicense['expiry_date'] ?? '';
    final dlCountry = driverLicense['country'] ?? '';

    final profile = json['profile'] ?? {};
    final workStatusStr = profile['work_status'] ?? '';
    final comment = profile['comment'] ?? '';
    final hireDate = profile['hire_date'] ?? '';

    final account = json['account'] ?? {};
    final balanceLimit = account['balance_limit'] ?? '';

    final carId = json['car_id'] ?? '';
    
    // В v2 API нет 'current_status' (свободен/занят), есть только 'work_status' (working, fired, etc.)
    // Баланс приходит в другой ручке, поэтому здесь ставим заглушку.
    StaffStatus status = StaffStatus.offline;
    if (workStatusStr == 'working') {
      status = StaffStatus.free; // Считаем, что если работает, то свободен (заглушка)
    } else if (workStatusStr == 'fired') {
      status = StaffStatus.fired;
    }

    return Staff(
      id: profileId,
      name: name.isEmpty ? 'Неизвестно' : name,
      initials: initials.isEmpty ? '?' : initials,
      status: status,
      timeOnShift: '0 ч 0 мин', // Заглушка, берется из другой ручки
      phoneNumber: phone,
      vehicleType: 'Авто',
      avatarUrl: '', // В v2 API driver-profile нет аватара
      balance: '0 ₽', // Берется из /v1/parks/contractors/blocked-balance
      email: email,
      address: address,
      taxNumber: taxNumber,
      employmentType: employmentTypeStr,
      comment: comment,
      balanceLimit: balanceLimit.toString(),
      hireDate: hireDate,
      carId: carId,
      driverLicenseNumber: dlNumber,
      driverLicenseIssueDate: dlIssue,
      driverLicenseExpiryDate: dlExpiry,
      driverLicenseCountry: dlCountry,
    );
  }

  // Парсинг из нового API: /v1/contractor-profile/contractor-data
  factory Staff.fromContractorDataJson(Map<String, dynamic> json) {
    final fullName = json['full_name'] ?? {};
    final firstName = fullName['first_name'] ?? '';
    final lastName = fullName['last_name'] ?? '';
    final middleName = fullName['middle_name'] ?? '';
    
    final nameParts = [lastName, firstName, middleName].where((e) => e.toString().isNotEmpty).toList();
    final name = nameParts.join(' ');
    
    String initials = '';
    if (lastName.toString().isNotEmpty) initials += lastName.toString()[0];
    if (firstName.toString().isNotEmpty) initials += firstName.toString()[0];

    final phone = json['phone'] ?? '';
    final taxNumber = json['tax_identification_number'] ?? '';
    final employmentTypeStr = json['employment_type'] ?? '';
    final comment = json['comment'] ?? '';
    
    final balance = json['balance'] ?? {};
    final balanceValue = balance['value'] ?? '0';
    final balanceCurrency = balance['currency'] ?? 'RUB';
    final balanceLimit = balance['limit'] ?? '';
    
    final car = json['car'] ?? {};
    final carId = car['id'] ?? '';
    
    final workStatusStr = json['work_status'] ?? '';
    final currentStatusStr = json['current_status'] ?? '';
    
    // Определяем статус
    StaffStatus status = StaffStatus.offline;
    if (currentStatusStr == 'online') {
      status = StaffStatus.free;
    } else if (currentStatusStr == 'busy') {
      status = StaffStatus.busy;
    } else if (currentStatusStr == 'in_order') {
      status = StaffStatus.onOrder;
    } else if (workStatusStr == 'fired') {
      status = StaffStatus.fired;
    }

    return Staff(
      id: json['id'] ?? '',
      name: name.isEmpty ? 'Неизвестно' : name,
      initials: initials.isEmpty ? '?' : initials,
      status: status,
      timeOnShift: '0 ч 0 мин',
      phoneNumber: phone,
      vehicleType: car['brand'] != null && car['model'] != null
          ? '${car['brand']} ${car['model']}'
          : 'Авто',
      avatarUrl: '',
      balance: '$balanceValue $balanceCurrency',
      email: '',
      address: '',
      taxNumber: taxNumber,
      employmentType: employmentTypeStr,
      comment: comment,
      balanceLimit: balanceLimit.toString(),
      hireDate: '',
      carId: carId,
      driverLicenseNumber: json['license_number'] ?? '',
      driverLicenseIssueDate: '',
      driverLicenseExpiryDate: '',
      driverLicenseCountry: '',
    );
  }
}
