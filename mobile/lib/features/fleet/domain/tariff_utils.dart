class TariffUtils {
  // Порядок тарифов важен - он определяет порядок отображения в UI
  static const Map<String, String> tariffNames = {
    'cargo': 'Грузовой',
    'econom': 'Эконом',
    'comfort': 'Комфорт',
    'comfort_plus': 'Комфорт+',
    'minivan': 'Минивэн',
    'express': 'Доставка',
    'business': 'Business',
    'ultimate': 'Premier',
    'premium_van': 'Минивэн Премиум',
    'personal_driver': 'Водитель',
    'maybach': 'VIP',
    'kids': 'Помощь детям',
    'premium_suv': 'Помощь взрослым',
    'ultima': 'Помощник Ultima',
    'vip': 'Élite',
    'standart': 'Стандарт',
    'start': 'Селект',
    'pool': 'Трансфер',
    'promo': 'Корпоративный',
  };

  static const Map<String, String> tariffIcons = {
    'cargo': 'assets/images/TariffEditSheet/cargo-B-G6Zmqn.png',
    'econom': 'assets/images/TariffEditSheet/economy-JKvI1sFo.png',
    'comfort': 'assets/images/TariffEditSheet/comfort-DIEi-5Q1.png',
    'comfort_plus': 'assets/images/TariffEditSheet/comfort-plus-COJ3b6fL.png',
    'minivan': 'assets/images/TariffEditSheet/minivan-DUvvmkPy.png',
    'express': 'assets/images/TariffEditSheet/intercity-DA1PvKH1.png',
    'business': 'assets/images/TariffEditSheet/business-rrEyyBjl.png',
    'ultimate': 'assets/images/TariffEditSheet/premier-D92IpG0F.png',
    'premium_van': 'assets/images/TariffEditSheet/cruise-4rvhlX_d.png',
    'personal_driver': 'assets/images/TariffEditSheet/driver-DVmVbvn5.png',
    'maybach': 'assets/images/TariffEditSheet/elite-CkitpAw2.png',
    'kids': 'assets/images/TariffEditSheet/kids-comfort-CUMQgl8r.png',
    'premium_suv': 'assets/images/TariffEditSheet/help-0rIz5SKA.png',
    'ultima': 'assets/images/TariffEditSheet/fallback-9U2fbpSe.png',
    'vip': 'assets/images/TariffEditSheet/elite-CkitpAw2.png',
    'standart': 'assets/images/TariffEditSheet/fallback-9U2fbpSe.png',
    'start': 'assets/images/TariffEditSheet/fallback-9U2fbpSe.png',
    'pool': 'assets/images/TariffEditSheet/fallback-9U2fbpSe.png',
    'promo': 'assets/images/TariffEditSheet/fallback-9U2fbpSe.png',
  };

  /// Преобразует список кодов тарифов в строку с русскими названиями
  static String getTariffNames(List<String> tariffs) {
    return tariffs.map((t) => tariffNames[t] ?? t).join(', ');
  }

  /// Получает русское название тарифа по коду
  static String getTariffName(String tariffCode) {
    return tariffNames[tariffCode] ?? tariffCode;
  }

  /// Получает код тарифа по русскому названию
  static String? getTariffCode(String tariffName) {
    return tariffNames.entries
        .firstWhere(
          (entry) => entry.value == tariffName,
          orElse: () => MapEntry(tariffName, tariffName),
        )
        .key;
  }
}
