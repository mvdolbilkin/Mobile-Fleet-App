import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/staff/domain/staff.dart';

void main() {
  // ─── fromContractorJson ───────────────────────────────────────────────────

  group('Staff.fromContractorJson', () {
    test('парсит полное имя и инициалы', () {
      final staff = Staff.fromContractorJson({
        'id': 'driver-1',
        'full_name': 'Иванов Иван',
        'phone': '+79001234567',
        'status': 'free',
        'balance': '1500',
        'avatar_url': 'https://example.com/avatar.jpg',
      });

      expect(staff.id, 'driver-1');
      expect(staff.name, 'Иванов Иван');
      expect(staff.initials, 'ИИ');
      expect(staff.status, StaffStatus.free);
      expect(staff.phoneNumber, '+79001234567');
      expect(staff.balance, '1500 ₽');
      expect(staff.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('статус busy парсится корректно', () {
      final staff = Staff.fromContractorJson({'status': 'busy', 'full_name': 'А Б'});
      expect(staff.status, StaffStatus.busy);
    });

    test('статус in_order парсится как onOrder', () {
      final staff = Staff.fromContractorJson({'status': 'in_order', 'full_name': 'А Б'});
      expect(staff.status, StaffStatus.onOrder);
    });

    test('статус on_order парсится как onOrder', () {
      final staff = Staff.fromContractorJson({'status': 'on_order', 'full_name': 'А Б'});
      expect(staff.status, StaffStatus.onOrder);
    });

    test('неизвестный статус → offline', () {
      final staff = Staff.fromContractorJson({'status': 'unknown_value', 'full_name': 'А Б'});
      expect(staff.status, StaffStatus.offline);
    });

    test('пустой json → дефолтные значения без ошибок', () {
      final staff = Staff.fromContractorJson({});
      expect(staff.id, '');
      expect(staff.name, 'Неизвестно');
      expect(staff.initials, '?');
      expect(staff.status, StaffStatus.offline);
      expect(staff.balance, '0 ₽');
    });

    test('одно слово в имени → одна буква инициала', () {
      final staff = Staff.fromContractorJson({'full_name': 'Иванов'});
      expect(staff.initials, 'И');
    });

    test('имя с пробелами → инициалы из первых двух слов', () {
      final staff = Staff.fromContractorJson({'full_name': 'Петров Пётр Иванович'});
      expect(staff.initials, 'ПП');
    });

    test('searchName и searchPhone — нижний регистр', () {
      final staff = Staff.fromContractorJson({
        'full_name': 'Иванов Иван',
        'phone': '+79001234567',
      });
      expect(staff.searchName, 'иванов иван');
      expect(staff.searchPhone, '+79001234567');
    });
  });

  // ─── fromJson (legacy staff list API) ────────────────────────────────────

  group('Staff.fromJson', () {
    test('парсит полное имя из driver_profile', () {
      final staff = Staff.fromJson({
        'driver_profile': {
          'id': 'profile-1',
          'last_name': 'Смирнов',
          'first_name': 'Алексей',
          'middle_name': 'Петрович',
          'phones': ['+79001112233'],
          'avatar_url': '',
        },
        'current_status': {'status': 'free'},
        'accounts': [],
      });

      expect(staff.name, 'Смирнов Алексей Петрович');
      expect(staff.initials, 'СА');
      expect(staff.status, StaffStatus.free);
      expect(staff.phoneNumber, '+79001112233');
    });

    test('work_status fired → StaffStatus.fired', () {
      final staff = Staff.fromJson({
        'driver_profile': {'work_status': 'fired', 'phones': []},
        'accounts': [],
      });
      expect(staff.status, StaffStatus.fired);
    });

    test('work_status not_working → StaffStatus.fired', () {
      final staff = Staff.fromJson({
        'driver_profile': {'work_status': 'not_working', 'phones': []},
        'accounts': [],
      });
      expect(staff.status, StaffStatus.fired);
    });

    test('баланс целое число форматируется без дробной части', () {
      final staff = Staff.fromJson({
        'driver_profile': {'phones': []},
        'accounts': [{'balance': '1000.0'}],
      });
      expect(staff.balance, '1000 ₽');
    });

    test('баланс с копейками форматируется с двумя знаками', () {
      final staff = Staff.fromJson({
        'driver_profile': {'phones': []},
        'accounts': [{'balance': '1500.50'}],
      });
      expect(staff.balance, '1500.50 ₽');
    });

    test('пустой список phones → пустой phoneNumber', () {
      final staff = Staff.fromJson({
        'driver_profile': {'phones': []},
        'accounts': [],
      });
      expect(staff.phoneNumber, '');
    });

    test('пустой json → не выбрасывает исключение', () {
      expect(() => Staff.fromJson({}), returnsNormally);
    });
  });

  // ─── fromV2ProfileJson ────────────────────────────────────────────────────

  group('Staff.fromV2ProfileJson', () {
    test('парсит имя, телефон, email из v2 профиля', () {
      final staff = Staff.fromV2ProfileJson('pid-123', {
        'person': {
          'full_name': {
            'last_name': 'Козлов',
            'first_name': 'Дмитрий',
            'middle_name': '',
          },
          'contact_info': {
            'phone': '+79009998877',
            'email': 'kozlov@mail.ru',
            'address': 'Москва',
          },
          'tax_identification_number': '123456789',
          'employment_type': 'self_employed',
          'driver_license': {
            'number': '77АА123456',
            'issue_date': '2015-01-01',
            'expiry_date': '2025-01-01',
            'country': 'RUS',
          },
        },
        'profile': {
          'work_status': 'working',
          'comment': 'Хороший водитель',
          'hire_date': '2020-06-01',
        },
        'account': {'balance_limit': '-500'},
        'car_id': 'car-999',
      });

      expect(staff.id, 'pid-123');
      expect(staff.name, 'Козлов Дмитрий');
      expect(staff.initials, 'КД');
      expect(staff.phoneNumber, '+79009998877');
      expect(staff.email, 'kozlov@mail.ru');
      expect(staff.taxNumber, '123456789');
      expect(staff.employmentType, 'self_employed');
      expect(staff.driverLicenseNumber, '77АА123456');
      expect(staff.driverLicenseCountry, 'RUS');
      expect(staff.carId, 'car-999');
      expect(staff.comment, 'Хороший водитель');
      expect(staff.hireDate, '2020-06-01');
      expect(staff.status, StaffStatus.free); // working → free
    });

    test('work_status fired → StaffStatus.fired', () {
      final staff = Staff.fromV2ProfileJson('p1', {
        'person': {'full_name': {}, 'contact_info': {}},
        'profile': {'work_status': 'fired'},
        'account': {},
      });
      expect(staff.status, StaffStatus.fired);
    });

    test('пустой v2 json → не выбрасывает исключение', () {
      expect(() => Staff.fromV2ProfileJson('p1', {}), returnsNormally);
    });
  });

  // ─── fromContractorDataJson ───────────────────────────────────────────────

  group('Staff.fromContractorDataJson', () {
    test('current_status online → StaffStatus.free', () {
      final staff = Staff.fromContractorDataJson({
        'id': 'c1',
        'current_status': 'online',
        'full_name': {'first_name': 'Иван', 'last_name': 'Петров'},
        'balance': {'value': '500', 'currency': 'RUB'},
        'car': {},
      });
      expect(staff.status, StaffStatus.free);
    });

    test('current_status busy → StaffStatus.busy', () {
      final staff = Staff.fromContractorDataJson({
        'current_status': 'busy',
        'full_name': {},
        'balance': {},
        'car': {},
      });
      expect(staff.status, StaffStatus.busy);
    });

    test('current_status in_order → StaffStatus.onOrder', () {
      final staff = Staff.fromContractorDataJson({
        'current_status': 'in_order',
        'full_name': {},
        'balance': {},
        'car': {},
      });
      expect(staff.status, StaffStatus.onOrder);
    });

    test('work_status fired → StaffStatus.fired', () {
      final staff = Staff.fromContractorDataJson({
        'work_status': 'fired',
        'full_name': {},
        'balance': {},
        'car': {},
      });
      expect(staff.status, StaffStatus.fired);
    });

    test('авто с brand и model формирует vehicleType', () {
      final staff = Staff.fromContractorDataJson({
        'full_name': {},
        'balance': {},
        'car': {'brand': 'Toyota', 'model': 'Camry'},
      });
      expect(staff.vehicleType, 'Toyota Camry');
    });

    test('баланс форматируется с валютой', () {
      final staff = Staff.fromContractorDataJson({
        'full_name': {},
        'balance': {'value': '2500', 'currency': 'RUB'},
        'car': {},
      });
      expect(staff.balance, '2500 RUB');
    });
  });

  // ─── copyWith ─────────────────────────────────────────────────────────────

  group('Staff.copyWith', () {
    final base = Staff(
      id: 'id-1',
      name: 'Иванов Иван',
      initials: 'ИИ',
      status: StaffStatus.free,
      timeOnShift: '1 ч 0 мин',
      phoneNumber: '+70000000000',
    );

    test('меняет только указанные поля', () {
      final updated = base.copyWith(status: StaffStatus.busy, balance: '999 ₽');
      expect(updated.id, 'id-1');
      expect(updated.name, 'Иванов Иван');
      expect(updated.status, StaffStatus.busy);
      expect(updated.balance, '999 ₽');
    });

    test('без аргументов возвращает копию с теми же данными', () {
      final copy = base.copyWith();
      expect(copy.id, base.id);
      expect(copy.name, base.name);
      expect(copy.status, base.status);
    });
  });
}
