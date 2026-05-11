import 'package:mobile/features/staff/domain/staff.dart';

final List<Staff> mockStaff = [
  Staff.fromV2ProfileJson('9b17db0cb1f24a38a5c3c8b4f6e4f63b', {
    "account": {
      "balance_limit": "50",
      "work_rule_id": "bc43tre6ba054dfdb7143ckfgvcby63e",
      "payment_service_id": "12345",
      "block_orders_on_balance_below_limit": true,
    },
    "person": {
      "full_name": {
        "first_name": "Иван",
        "middle_name": "Иванович",
        "last_name": "Иванов",
      },
      "contact_info": {
        "address": "Moscow, Ivanovskaya Ul., bld. 40/2, appt. 63",
        "email": "example-email@example.com",
        "phone": "+79999999999",
      },
      "tax_identification_number": "7743013902",
      "employment_type": "selfemployed",
    },
    "profile": {
      "hire_date": "2020-10-28",
      "work_status": "working",
      "fire_date": "2020-10-28",
      "comment": "Отличный водитель, всегда вовремя",
      "feedback": "great driver",
    },
    "car_id": "5011ade6ba054dfdb7143c8cc9460dbc",
  }),
  Staff(
    id: '2',
    name: 'Иванов Иван Иванович',
    initials: 'ИИ',
    status: StaffStatus.busy,
    timeOnShift: '4 ч 20 мин',
    phoneNumber: '+7 900 123 45 67',
    vehicleType: 'Мото',
  ),
  Staff(
    id: '3',
    name: 'Петров Петр Петрович',
    initials: 'ПП',
    status: StaffStatus.offline,
    timeOnShift: '0 мин',
    phoneNumber: '+7 999 888 77 66',
    vehicleType: 'Рикша',
  ),
  Staff(
    id: '4',
    name: 'Сидоров Сидор Сидорович',
    initials: 'СС',
    status: StaffStatus.onOrder,
    timeOnShift: '2 ч 15 мин',
    phoneNumber: '+7 911 222 33 44',
  ),
  Staff(
    id: '5',
    name: 'Смирнов Алексей Владимирович',
    initials: 'СА',
    status: StaffStatus.free,
    timeOnShift: '6 ч 45 мин',
    phoneNumber: '+7 922 333 44 55',
  ),
];
