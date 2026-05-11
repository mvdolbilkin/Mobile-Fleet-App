import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/fleet/domain/tariff_utils.dart';

void main() {
  group('TariffUtils.getTariffName', () {
    test('econom → Эконом', () => expect(TariffUtils.getTariffName('econom'), 'Эконом'));
    test('comfort → Комфорт', () => expect(TariffUtils.getTariffName('comfort'), 'Комфорт'));
    test('comfort_plus → Комфорт+', () => expect(TariffUtils.getTariffName('comfort_plus'), 'Комфорт+'));
    test('business → Business', () => expect(TariffUtils.getTariffName('business'), 'Business'));
    test('maybach → VIP', () => expect(TariffUtils.getTariffName('maybach'), 'VIP'));
    test('неизвестный код → код как есть', () => expect(TariffUtils.getTariffName('my_tariff'), 'my_tariff'));
  });

  group('TariffUtils.getTariffNames', () {
    test('список кодов → строка через запятую', () {
      expect(TariffUtils.getTariffNames(['econom', 'comfort']), 'Эконом, Комфорт');
    });
    test('один тариф', () => expect(TariffUtils.getTariffNames(['business']), 'Business'));
    test('пустой список → пустая строка', () => expect(TariffUtils.getTariffNames([]), ''));
    test('неизвестный код в списке → как есть', () {
      expect(TariffUtils.getTariffNames(['econom', 'custom']), 'Эконом, custom');
    });
  });

  group('TariffUtils.getTariffCode', () {
    test('Эконом → econom', () => expect(TariffUtils.getTariffCode('Эконом'), 'econom'));
    test('Комфорт+ → comfort_plus', () => expect(TariffUtils.getTariffCode('Комфорт+'), 'comfort_plus'));
    test('несуществующее → возвращает само значение', () {
      expect(TariffUtils.getTariffCode('Неизвестный'), 'Неизвестный');
    });
  });
}
