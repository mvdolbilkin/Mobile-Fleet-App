import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/fleet/domain/vehicle.dart';

void main() {
  // ─── fromJson ─────────────────────────────────────────────────────────────

  group('Vehicle.fromJson', () {
    test('парсит полный объект корректно', () {
      final v = Vehicle.fromJson({
        'id': 'v-1',
        'number': 'А123ВВ',
        'model': 'Toyota Camry',
        'year': 2022,
        'color_name': 'Чёрный',
        'status': 'working',
        'mileage': 55000,
        'brand': 'Toyota',
        'callsign': 'TC-01',
        'vin': 'VIN123456789',
        'transmission': 'automatic',
        'fuel_type': 'gasoline',
        'is_park_property': true,
        'amenities': ['wifi', 'usb'],
        'category': ['comfort'],
        'tariffs': ['comfort', 'econom'],
      });

      expect(v.id, 'v-1');
      expect(v.plateNumber, 'А123ВВ');
      expect(v.model, 'Toyota Camry');
      expect(v.year, '2022');
      expect(v.color, 'Чёрный');
      expect(v.status, VehicleStatus.working);
      expect(v.mileage, 55000);
      expect(v.brand, 'Toyota');
      expect(v.vin, 'VIN123456789');
      expect(v.transmission, 'automatic');
      expect(v.isParkProperty, isTrue);
      expect(v.amenities, ['wifi', 'usb']);
      expect(v.tariffs, ['comfort', 'econom']);
      expect(v.category, VehicleCategory.comfort); // через 'category' ключ
    });

    test('status как объект {id, name}', () {
      final v = Vehicle.fromJson({
        'id': 'v-2',
        'status': {'id': 'not_working', 'name': 'Не работает'},
      });
      expect(v.status, VehicleStatus.notWorking);
    });

    test('status как строка repairing → service', () {
      final v = Vehicle.fromJson({'status': 'repairing'});
      expect(v.status, VehicleStatus.service);
    });

    test('status no_driver → noDriver', () {
      final v = Vehicle.fromJson({'status': 'no_driver'});
      expect(v.status, VehicleStatus.noDriver);
    });

    test('status pending → preparation', () {
      final v = Vehicle.fromJson({'status': 'pending'});
      expect(v.status, VehicleStatus.preparation);
    });

    test('неизвестный status → other', () {
      final v = Vehicle.fromJson({'status': 'some_new_status'});
      expect(v.status, VehicleStatus.other);
    });

    test('пустой json → дефолтные значения без исключения', () {
      final v = Vehicle.fromJson({});
      expect(v.id, '');
      expect(v.plateNumber, 'Нет номера');
      expect(v.model, 'Неизвестная модель');
      expect(v.mileage, 0);
      expect(v.status, VehicleStatus.other);
      expect(v.category, VehicleCategory.econom);
    });

    test('color fallback: color_name → color', () {
      final v = Vehicle.fromJson({'color': 'Белый'});
      expect(v.color, 'Белый');
    });
  });

  // ─── _parseCategory ───────────────────────────────────────────────────────

  group('Vehicle._parseCategory', () {
    final categories = {
      'comfort': VehicleCategory.comfort,
      'comfort_plus': VehicleCategory.comfortPlus,
      'business': VehicleCategory.business,
      'minivan': VehicleCategory.minivan,
      'vip': VehicleCategory.vip,
      'wagon': VehicleCategory.wagon,
      'pool': VehicleCategory.pool,
      'start': VehicleCategory.start,
      'standart': VehicleCategory.standart,
      'ultimate': VehicleCategory.ultimate,
      'maybach': VehicleCategory.maybach,
      'promo': VehicleCategory.promo,
      'premium_van': VehicleCategory.premiumVan,
      'premium_suv': VehicleCategory.premiumSuv,
      'suv': VehicleCategory.suv,
      'personal_driver': VehicleCategory.personalDriver,
      'express': VehicleCategory.express,
      'cargo': VehicleCategory.cargo,
      'econom': VehicleCategory.econom,
    };

    for (final entry in categories.entries) {
      test('${entry.key} → ${entry.value}', () {
        // _parseCategory читает json['category'] (ед. ч.), не 'categories'
        final v = Vehicle.fromJson({'category': [entry.key]});
        expect(v.category, entry.value);
      });
    }

    test('null category → econom по умолчанию', () {
      final v = Vehicle.fromJson({'category': null});
      expect(v.category, VehicleCategory.econom);
    });

    test('пустой список category → econom по умолчанию', () {
      final v = Vehicle.fromJson({'category': []});
      expect(v.category, VehicleCategory.econom);
    });
  });

  // ─── VehicleCategory.id ───────────────────────────────────────────────────

  group('VehicleCategory.id', () {
    test('comfortPlus.id = comfort_plus', () {
      expect(VehicleCategory.comfortPlus.id, 'comfort_plus');
    });

    test('premiumVan.id = premium_van', () {
      expect(VehicleCategory.premiumVan.id, 'premium_van');
    });

    test('econom.id = econom', () {
      expect(VehicleCategory.econom.id, 'econom');
    });
  });

  // ─── VehicleCategory.fromId ───────────────────────────────────────────────

  group('VehicleCategory.fromId', () {
    test('fromId("comfort") → VehicleCategory.comfort', () {
      expect(VehicleCategory.fromId('comfort'), VehicleCategory.comfort);
    });

    test('fromId("comfort_plus") → comfortPlus', () {
      expect(VehicleCategory.fromId('comfort_plus'), VehicleCategory.comfortPlus);
    });

    test('fromId("unknown") → null', () {
      expect(VehicleCategory.fromId('unknown'), isNull);
    });
  });
}
