import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/fleet/domain/expense.dart';

void main() {
  // ─── Expense.fromYandexApi ────────────────────────────────────────────────

  group('Expense.fromYandexApi', () {
    test('парсит полный объект', () {
      final e = Expense.fromYandexApi({
        'id': 'exp-1',
        'car': {
          'id': 'car-1',
          'brand': 'Toyota',
          'model': 'Camry',
          'color': 'Чёрный',
          'year': 2022,
          'number': 'А123ВВ',
        },
        'date': '2024-05-15',
        'name': 'ТО',
        'type': {'id': 'maintenance', 'name': 'Обслуживание'},
        'amount': 1500,
        'paid_at': '2024-05-16',
        'created_by_user_name': 'Менеджер',
        'is_deleted': false,
      });

      expect(e.id, 'exp-1');
      expect(e.car.brand, 'Toyota');
      expect(e.car.number, 'А123ВВ');
      expect(e.date, '2024-05-15');
      expect(e.amount, '1500');
      expect(e.type.id, 'maintenance');
      expect(e.isDeleted, isFalse);
    });

    test('amount как число int', () {
      final e = Expense.fromYandexApi({'amount': 750, 'date': '2024-01-01'});
      expect(e.amount, '750');
    });

    test('amount как строка', () {
      final e = Expense.fromYandexApi({'amount': '2500.99', 'date': '2024-01-01'});
      expect(e.amount, '2501');
    });

    test('amount null → 0', () {
      final e = Expense.fromYandexApi({'date': '2024-01-01'});
      expect(e.amount, '0');
    });

    test('невалидная дата → не выбрасывает исключение', () {
      expect(
        () => Expense.fromYandexApi({'date': 'not-a-date', 'amount': 0}),
        returnsNormally,
      );
    });

    test('пустой json → не выбрасывает исключение', () {
      expect(() => Expense.fromYandexApi({}), returnsNormally);
    });
  });

  // ─── Expense.formattedDate ────────────────────────────────────────────────

  group('Expense.formattedDate', () {
    Expense makeExpense(String date) => Expense.fromYandexApi({
          'date': date,
          'amount': 0,
        });

    test('январь', () {
      expect(makeExpense('2024-01-05').formattedDate, '5 янв.');
    });

    test('май', () {
      expect(makeExpense('2024-05-20').formattedDate, '20 мая');
    });

    test('декабрь', () {
      expect(makeExpense('2024-12-31').formattedDate, '31 дек.');
    });

    test('июнь', () {
      expect(makeExpense('2024-06-01').formattedDate, '1 июн.');
    });
  });

  // ─── ExpenseCar.details ───────────────────────────────────────────────────

  group('ExpenseCar.details', () {
    test('возвращает brand model year color', () {
      final car = ExpenseCar(
        id: 'c1',
        brand: 'Jeep',
        model: 'Grand Cherokee',
        color: 'Голубой',
        year: 2021,
        number: 'А123АА',
      );
      expect(car.details, 'Jeep Grand Cherokee 2021 Голубой');
    });
  });
}
