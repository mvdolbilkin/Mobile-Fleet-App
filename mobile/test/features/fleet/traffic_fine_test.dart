import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/fleet/domain/traffic_fine.dart';

void main() {
  // ─── TrafficFine.fromJson ─────────────────────────────────────────────────

  group('TrafficFine.fromJson', () {
    final baseJson = {
      'vehicle': {
        'id': 'car-1',
        'license_plate': 'А111АА77',
        'brand': 'Toyota',
        'model': 'Camry',
        'is_stopped_updating_fines': false,
      },
      'contractor': {
        'status': 'active',
        'contractor_id': 'drv-1',
        'name': 'Иван Петров',
        'payment': {'status': 'completed', 'amount': '500'},
      },
      'fine': {
        'uin': 'UIN123',
        'status': 'issued',
        'issued_at': '2024-03-15T10:00:00Z',
        'amount': '1000',
        'paid_amount': '0',
        'payment': '500',
        'number_of_photos': 2,
        'offense_at': '2024-03-14T09:00:00Z',
        'offense_address': 'ул. Пушкина, д. 1',
      },
      'was_loaded_bank_client': true,
      'loaded_at': '2024-03-15T12:00:00Z',
    };

    test('парсит полный объект', () {
      final fine = TrafficFine.fromJson(baseJson);

      expect(fine.wasLoadedBankClient, isTrue);
      expect(fine.loadedAt, DateTime.parse('2024-03-15T12:00:00Z'));
      expect(fine.vehicle!.licensePlate, 'А111АА77');
      expect(fine.vehicle!.brand, 'Toyota');
      expect(fine.contractor.name, 'Иван Петров');
      expect(fine.contractor.status, 'active');
      expect(fine.fine.uin, 'UIN123');
      expect(fine.fine.amount, '1000');
      expect(fine.fine.numberOfPhotos, 2);
    });

    test('vehicle nullable — работает без vehicle', () {
      final json = Map<String, dynamic>.from(baseJson);
      json['vehicle'] = null;
      final fine = TrafficFine.fromJson(json);
      expect(fine.vehicle, isNull);
    });
  });

  // ─── TrafficFineVehicle ───────────────────────────────────────────────────

  group('TrafficFineVehicle', () {
    test('displayName = brand + model', () {
      final v = TrafficFineVehicle(
        id: '1',
        licensePlate: 'А111АА',
        brand: 'Toyota',
        model: 'Camry',
        isStoppedUpdatingFines: false,
      );
      expect(v.displayName, 'Toyota Camry');
    });

    test('fromJson парсит корректно', () {
      final v = TrafficFineVehicle.fromJson({
        'id': 'v-1',
        'license_plate': 'В222ВВ',
        'brand': 'Honda',
        'model': 'Accord',
        'is_stopped_updating_fines': true,
        'registration_cert': 'CERT-123',
      });
      expect(v.id, 'v-1');
      expect(v.isStoppedUpdatingFines, isTrue);
      expect(v.registrationCert, 'CERT-123');
    });
  });

  // ─── TrafficFineContractor.displayName ───────────────────────────────────

  group('TrafficFineContractor.displayName', () {
    test('возвращает name если есть', () {
      final c = TrafficFineContractor(
        status: 'active',
        name: 'Иван Петров',
        payment: TrafficFinePayment(status: 'completed'),
      );
      expect(c.displayName, 'Иван Петров');
    });

    test('status missing → Определяем водителя', () {
      final c = TrafficFineContractor(
        status: 'missing',
        payment: TrafficFinePayment(status: 'planned'),
      );
      expect(c.displayName, 'Определяем водителя');
    });

    test('status planned → Определяем водителя', () {
      final c = TrafficFineContractor(
        status: 'planned',
        payment: TrafficFinePayment(status: 'planned'),
      );
      expect(c.displayName, 'Определяем водителя');
    });

    test('пустое name → Не назначен', () {
      final c = TrafficFineContractor(
        status: 'other',
        name: '',
        payment: TrafficFinePayment(status: 'planned'),
      );
      expect(c.displayName, 'Не назначен');
    });
  });

  // ─── TrafficFineDetails.statusDisplayName ────────────────────────────────

  group('TrafficFineDetails.statusDisplayName', () {
    TrafficFineDetails makeDetails(String status) => TrafficFineDetails(
          uin: 'U',
          status: status,
          issuedAt: DateTime(2024),
          amount: '1000',
          paidAmount: '0',
          payment: '0',
          numberOfPhotos: 0,
        );

    test('issued → Не оплачен', () {
      expect(makeDetails('issued').statusDisplayName, 'Не оплачен');
    });

    test('paid → Оплачен', () {
      expect(makeDetails('paid').statusDisplayName, 'Оплачен');
    });

    test('overdue → Просрочен', () {
      expect(makeDetails('overdue').statusDisplayName, 'Просрочен');
    });

    test('неизвестный статус возвращается как есть', () {
      expect(makeDetails('cancelled').statusDisplayName, 'cancelled');
    });
  });

  // ─── TrafficFinesTotal.fromJson ───────────────────────────────────────────

  group('TrafficFinesTotal.fromJson', () {
    test('читает из total-объекта', () {
      final t = TrafficFinesTotal.fromJson({
        'total': {'count': 5, 'sum': '2500'},
      });
      expect(t.count, 5);
      expect(t.sum, '2500');
    });

    test('читает напрямую без обёртки total', () {
      final t = TrafficFinesTotal.fromJson({'count': 3, 'sum': '1500'});
      expect(t.count, 3);
      expect(t.sum, '1500');
    });

    test('пустой json → 0 и 0', () {
      final t = TrafficFinesTotal.fromJson({});
      expect(t.count, 0);
      expect(t.sum, '0');
    });
  });

  // ─── FineStatusFilterExt.displayName ─────────────────────────────────────

  group('FineStatusFilter.displayName', () {
    test('all → Все', () {
      expect(FineStatusFilter.all.displayName, 'Все');
    });

    test('unpaid → Неоплаченные', () {
      expect(FineStatusFilter.unpaid.displayName, 'Неоплаченные');
    });

    test('paid → Оплаченные', () {
      expect(FineStatusFilter.paid.displayName, 'Оплаченные');
    });

    test('overdue → Просроченные', () {
      expect(FineStatusFilter.overdue.displayName, 'Просроченные');
    });

    test('paymentSent → Оплата отправлена', () {
      expect(FineStatusFilter.paymentSent.displayName, 'Оплата отправлена');
    });
  });
}
