# Mobile Fleet App (Flutter)

Мобильное приложение для управления автопарком на базе Yandex Fleet API.

## Технологии

| Стек | Версия |
|---|---|
| **Flutter** | SDK ^3.10 |
| **Dart** | ^3.10 |
| **flutter_riverpod** | ^3.2 — state management |
| **go_router** | ^17.0 — навигация |
| **dio** | ^5.9 — HTTP-клиент |
| **flutter_inappwebview** | ^6.1 — WebView для авторизации |
| **flutter_secure_storage** | ^10.0 — безопасное хранение токенов |
| **yandex_maps_mapkit** | 4.25-beta — карты |
| **fl_chart** | ^1.2 — графики |
| **flutter_hooks** | ^0.21 — хуки |
| **cached_network_image** | ^3.4 — кэширование изображений |

## Модули (lib/features/)

| Модуль | Описание |
|---|---|
| `auth` | Авторизация (WebView + API-ключи) |
| `staff` | Управление водителями |
| `fleet` | Транспортные средства |
| `reports` | Отчёты и финансы |
| `map` | Яндекс Карты с геолокацией водителей |
| `summary` | Дашборд со статистикой |
| `competitions` | Соревнования |
| `goals` | Цели |
| `mailings` | Рассылки |
| `work_rules` | Условия работы |
| `menu` | Навигационное меню |

## Настройка

Создайте файл `mobile/.env` (или просто `.env` в корне папки `mobile`). 
*Важно:* Для запуска на реальном устройстве `localhost` работать не будет! Укажите локальный IP-адрес вашего компьютера (например, `192.168.x.x`). 
- **iOS эмулятор / Desktop:** `http://localhost:8081`
- **Android эмулятор:** `http://10.0.2.2:8081`
- **Реальное устройство:** `http://<YOUR_LOCAL_IP>:8081`

```env
API_BASE_URL=http://<IP_ИЗ_СПИСКА_ВЫШЕ>:8081
```

## Запуск

```bash
# Установить зависимости
flutter pub get

# Запустить на подключённом устройстве или эмуляторе
flutter run

# Собрать APK
flutter build apk --release
```

## Шрифты

Приложение использует шрифты **Yandex Sans Text** и **Yandex Sans Display** (включены в `assets/fonts/`).

## Тесты

### Требования

Установить зависимости (включая `mocktail` для моков):

```bash
flutter pub get
```

### Запуск тестов

```bash
# Стандартный вывод
flutter test

# Подробный вывод с именами каждого теста
flutter test --reporter expanded
```

### Покрытие кода

```bash
# Генерировать отчёт покрытия
flutter test --coverage

# Открыть HTML-отчёт (требует lcov)
# macOS/Linux:
genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html

# Windows (через lcov в WSL или scoop):
genhtml coverage/lcov.info -o coverage/html
```

> Файл покрытия сохраняется в `coverage/lcov.info`.
