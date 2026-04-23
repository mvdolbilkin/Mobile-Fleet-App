class Expense {
  final String id;
  final ExpenseCar car;
  final String date;
  final String name;
  final ExpenseType type;
  final String amount;
  final String createdByUserName;
  final bool isDeleted;

  Expense({
    required this.id,
    required this.car,
    required this.date,
    required this.name,
    required this.type,
    required this.amount,
    required this.createdByUserName,
    required this.isDeleted,
  });

  String get formattedDate {
    try {
      final parts = date.split('-');
      final day = int.parse(parts[2]);
      final month = int.parse(parts[1]);
      const months = [
        'янв.',
        'фев.',
        'мар.',
        'апр.',
        'мая',
        'июн.',
        'июл.',
        'авг.',
        'сен.',
        'окт.',
        'ноя.',
        'дек.',
      ];
      return '$day ${months[month - 1]}';
    } catch (e) {
      return date;
    }
  }
}

class ExpenseCar {
  final String id;
  final String brand;
  final String model;
  final String color;
  final int year;
  final String number;

  ExpenseCar({
    required this.id,
    required this.brand,
    required this.model,
    required this.color,
    required this.year,
    required this.number,
  });

  String get details => '$brand $model $year $color';
}

class ExpenseType {
  final String id;
  final String name;

  ExpenseType({required this.id, required this.name});
}

final List<Expense> mockExpenses = [
  Expense(
    id: "770bf659-0862-4c24-8cfd-fc579b1bed38",
    car: ExpenseCar(
      id: "464cdc182b864fe19bc15796ed16eb3f",
      brand: "Jeep",
      model: "Wrangler",
      color: "Синий",
      year: 2026,
      number: "В123ВВВ",
    ),
    date: "2026-01-21",
    name: "notch",
    type: ExpenseType(id: "loan", name: "Кредит"),
    amount: "1",
    createdByUserName: "Алина Привалова",
    isDeleted: false,
  ),
  Expense(
    id: "1d96ea7d-de02-4beb-baf7-59b326ee73ff",
    car: ExpenseCar(
      id: "464cdc182b864fe19bc15796ed16eb3f",
      brand: "Jeep",
      model: "Wrangler",
      color: "Синий",
      year: 2026,
      number: "В123ВВВ",
    ),
    date: "2026-01-21",
    name: "3",
    type: ExpenseType(id: "petrol", name: "Бензин"),
    amount: "4",
    createdByUserName: "Алина Привалова",
    isDeleted: true,
  ),
  Expense(
    id: "d57246d4-59f5-47d7-939c-70731fcb84e6",
    car: ExpenseCar(
      id: "fffeb9d49a30d6dde5e87ef7dd90bcbb",
      brand: "Apollo",
      model: "Rio",
      color: "Белый",
      year: 2000,
      number: "Р544ТР159",
    ),
    date: "2026-01-21",
    name: "1",
    type: ExpenseType(id: "service", name: "Ремонт"),
    amount: "1",
    createdByUserName: "Алина Привалова",
    isDeleted: true,
  ),
  Expense(
    id: "9dd09808-11d3-432f-b152-607737c2476e",
    car: ExpenseCar(
      id: "7a664f23a5ae4d06b7dee6cd9ebe868a",
      brand: "Jeep",
      model: "Grand Cherokee",
      color: "Голубой",
      year: 2021,
      number: "А123ААА",
    ),
    date: "2026-01-21",
    name: "TEst1",
    type: ExpenseType(id: "subrent", name: "Субаренда"),
    amount: "5",
    createdByUserName: "Алина Привалова",
    isDeleted: true,
  ),
  Expense(
    id: "18bd05d3-b386-4b8a-9e7f-e029b77c7209",
    car: ExpenseCar(
      id: "7a664f23a5ae4d06b7dee6cd9ebe868a",
      brand: "Jeep",
      model: "Grand Cherokee",
      color: "Голубой",
      year: 2021,
      number: "А123ААА",
    ),
    date: "2026-01-21",
    name: "ремонт тест",
    type: ExpenseType(id: "service", name: "Ремонт"),
    amount: "1",
    createdByUserName: "Алина Привалова",
    isDeleted: true,
  ),
  Expense(
    id: "3ced502b-9a81-4aaa-b5a5-c5a3d709297f",
    car: ExpenseCar(
      id: "464cdc182b864fe19bc15796ed16eb3f",
      brand: "Jeep",
      model: "Wrangler",
      color: "Синий",
      year: 2026,
      number: "В123ВВВ",
    ),
    date: "2026-01-21",
    name: "1",
    type: ExpenseType(id: "maintenance", name: "Техническое обслуживание"),
    amount: "3",
    createdByUserName: "Алина Привалова",
    isDeleted: true,
  ),
];
