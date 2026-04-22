import 'package:mobile/features/staff/domain/staff.dart';

final List<Staff> mockStaff = [
  Staff(
    id: '1',
    name: 'Аюпов Альберт Рифович',
    initials: 'AC',
    status: StaffStatus.onOrder,
    timeOnShift: '8 ч 56 мин',
    phoneNumber: '+7 817 409 21 56',
  ),
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
