import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/fleet/domain/posting.dart';

void main() {
  final baseJson = {
    'posting_id': 'post-1',
    'park_id': 'park-1',
    'brand': 'Toyota',
    'model': 'Camry',
    'year': 2022,
    'fuel_type': {'value': 'gasoline', 'label': 'Бензин'},
    'transmission': {'value': 'automatic', 'label': 'Автомат'},
    'office': {'office_id': 'office-1', 'address': 'ул. Ленина, 1'},
    'status': 'posted',
    'vehicle_info': {'total': 10, 'posted_count': 3},
    'images': ['img1.jpg', 'img2.jpg'],
  };

  group('Posting.fromJson', () {
    test('парсит полный объект', () {
      final p = Posting.fromJson(baseJson);
      expect(p.postingId, 'post-1');
      expect(p.brand, 'Toyota');
      expect(p.model, 'Camry');
      expect(p.year, 2022);
      expect(p.fuelType.label, 'Бензин');
      expect(p.transmission.label, 'Автомат');
      expect(p.office.address, 'ул. Ленина, 1');
      expect(p.vehicleInfo.total, 10);
      expect(p.vehicleInfo.postedCount, 3);
      expect(p.images, ['img1.jpg', 'img2.jpg']);
    });

    test('пустой json → не выбрасывает исключение', () {
      expect(() => Posting.fromJson({}), returnsNormally);
    });
  });

  group('Posting.title', () {
    test('возвращает brand + model + year', () {
      final p = Posting.fromJson(baseJson);
      expect(p.title, 'Toyota Camry 2022');
    });
  });

  group('Posting.availabilityText', () {
    test('возвращает правильный текст', () {
      final p = Posting.fromJson(baseJson);
      expect(p.availabilityText, '3 свободно из 10');
    });
  });

  group('Posting.statusLabel', () {
    test('posted → Опубликовано в Гараже', () {
      final p = Posting.fromJson(baseJson);
      expect(p.statusLabel, 'Опубликовано в Гараже');
      expect(p.isPublished, isTrue);
    });

    test('not_posted → Не опубликовано', () {
      final p = Posting.fromJson({...baseJson, 'status': 'not_posted'});
      expect(p.statusLabel, 'Не опубликовано');
      expect(p.isPublished, isFalse);
    });

    test('without_rent_rule → Укажите условия аренды', () {
      final p = Posting.fromJson({...baseJson, 'status': 'without_rent_rule'});
      expect(p.statusLabel, 'Укажите условия аренды');
    });

    test('неизвестный статус → возвращается как есть', () {
      final p = Posting.fromJson({...baseJson, 'status': 'draft'});
      expect(p.statusLabel, 'draft');
    });
  });
}
