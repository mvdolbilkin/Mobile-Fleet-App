import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/auth/auth_service.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';

// ─── Моки ────────────────────────────────────────────────────────────────────

class MockDio extends Mock implements Dio {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockDio mockDio;
  late MockSecureStorageService mockStorage;
  late AuthService authService;

  setUpAll(() async {
    // flutter_dotenv 6.x: load() с isOptional=true не падает если .env нет в assets,
    // mergeWith добавляет нужные переменные для тестов
    await dotenv.load(
      mergeWith: {'API_BASE_URL': 'http://localhost:8080'},
      isOptional: true,
    );
  });

  setUp(() {
    mockDio = MockDio();
    mockStorage = MockSecureStorageService();
    authService = AuthService(mockDio, mockStorage);
  });

  // ─── login() ─────────────────────────────────────────────────────────────

  group('AuthService.login', () {
    test('возвращает true и сохраняет credentials при успешном ответе', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: {'success': true},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      when(() => mockStorage.saveYandexCredentials(
            clid: any(named: 'clid'),
            apiKey: any(named: 'apiKey'),
            parkId: any(named: 'parkId'),
          )).thenAnswer((_) async {});

      final result = await authService.login(
        clid: 'clid-1',
        apiKey: 'key-1',
        parkId: 'park-1',
      );

      expect(result, isTrue);
      verify(() => mockStorage.saveYandexCredentials(
            clid: 'clid-1',
            apiKey: 'key-1',
            parkId: 'park-1',
          )).called(1);
    });

    test('возвращает false если success != true', () async {
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {'success': false},
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final result = await authService.login(
        clid: 'c', apiKey: 'k', parkId: 'p',
      );
      expect(result, isFalse);
      verifyNever(() => mockStorage.saveYandexCredentials(
            clid: any(named: 'clid'),
            apiKey: any(named: 'apiKey'),
            parkId: any(named: 'parkId'),
          ));
    });

    test('возвращает false при DioException (сетевая ошибка)', () async {
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionError,
          ));

      final result = await authService.login(
        clid: 'c', apiKey: 'k', parkId: 'p',
      );
      expect(result, isFalse);
    });

    test('возвращает false при statusCode != 200', () async {
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {'error': 'Unauthorized'},
                statusCode: 401,
                requestOptions: RequestOptions(path: ''),
              ));

      final result = await authService.login(
        clid: 'c', apiKey: 'k', parkId: 'p',
      );
      expect(result, isFalse);
    });
  });

  // ─── checkAuthAndLogin() ─────────────────────────────────────────────────

  group('AuthService.checkAuthAndLogin', () {
    test('возвращает true если есть sessionId и sessionId2 (WebView-сессия)', () async {
      when(() => mockStorage.getYandexSessionId())
          .thenAnswer((_) async => 'session-1');
      when(() => mockStorage.getYandexSessionId2())
          .thenAnswer((_) async => 'session-2');

      final result = await authService.checkAuthAndLogin();
      expect(result, isTrue);

      // Не должно идти в сеть если cookies уже есть
      verifyNever(() => mockDio.post(any(), data: any(named: 'data')));
    });

    test('возвращает false если sessionId пустой', () async {
      when(() => mockStorage.getYandexSessionId())
          .thenAnswer((_) async => '');
      when(() => mockStorage.getYandexSessionId2())
          .thenAnswer((_) async => 'session-2');
      when(() => mockStorage.getClid()).thenAnswer((_) async => null);
      when(() => mockStorage.getApiKey()).thenAnswer((_) async => null);
      when(() => mockStorage.getParkId()).thenAnswer((_) async => null);

      final result = await authService.checkAuthAndLogin();
      expect(result, isFalse);
    });

    test('возвращает false если все хранилища пусты', () async {
      when(() => mockStorage.getYandexSessionId()).thenAnswer((_) async => null);
      when(() => mockStorage.getYandexSessionId2()).thenAnswer((_) async => null);
      when(() => mockStorage.getClid()).thenAnswer((_) async => null);
      when(() => mockStorage.getApiKey()).thenAnswer((_) async => null);
      when(() => mockStorage.getParkId()).thenAnswer((_) async => null);

      final result = await authService.checkAuthAndLogin();
      expect(result, isFalse);
    });

    test('пробует API-ключи если нет cookies, удаляет при неуспехе', () async {
      when(() => mockStorage.getYandexSessionId()).thenAnswer((_) async => null);
      when(() => mockStorage.getYandexSessionId2()).thenAnswer((_) async => null);
      when(() => mockStorage.getClid()).thenAnswer((_) async => 'clid-1');
      when(() => mockStorage.getApiKey()).thenAnswer((_) async => 'key-1');
      when(() => mockStorage.getParkId()).thenAnswer((_) async => 'park-1');

      // login() вернёт false (сервер недоступен)
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionError,
          ));
      when(() => mockStorage.deleteYandexCredentials()).thenAnswer((_) async {});

      final result = await authService.checkAuthAndLogin();
      expect(result, isFalse);
      verify(() => mockStorage.deleteYandexCredentials()).called(1);
    });
  });

  // ─── hasCookies() ─────────────────────────────────────────────────────────

  group('AuthService.hasCookies', () {
    test('возвращает true если оба session ID есть', () async {
      when(() => mockStorage.getYandexSessionId())
          .thenAnswer((_) async => 'sid-1');
      when(() => mockStorage.getYandexSessionId2())
          .thenAnswer((_) async => 'sid-2');

      expect(await authService.hasCookies(), isTrue);
    });

    test('возвращает false если sessionId2 отсутствует', () async {
      when(() => mockStorage.getYandexSessionId())
          .thenAnswer((_) async => 'sid-1');
      when(() => mockStorage.getYandexSessionId2())
          .thenAnswer((_) async => null);

      expect(await authService.hasCookies(), isFalse);
    });

    test('возвращает false если оба null', () async {
      when(() => mockStorage.getYandexSessionId()).thenAnswer((_) async => null);
      when(() => mockStorage.getYandexSessionId2()).thenAnswer((_) async => null);

      expect(await authService.hasCookies(), isFalse);
    });
  });

  // ─── saveYandexCookies() ──────────────────────────────────────────────────

  group('AuthService.saveYandexCookies', () {
    test('делегирует вызов в SecureStorageService', () async {
      when(() => mockStorage.saveYandexCookies(
            sessionId: any(named: 'sessionId'),
            sessionId2: any(named: 'sessionId2'),
            loginToken: any(named: 'loginToken'),
            yandexLogin: any(named: 'yandexLogin'),
            yandexUid: any(named: 'yandexUid'),
          )).thenAnswer((_) async {});

      await authService.saveYandexCookies(
        sessionId: 'sid-1',
        sessionId2: 'sid-2',
        loginToken: 'token-abc',
        yandexLogin: 'user@yandex.ru',
        yandexUid: 'uid-123',
      );

      verify(() => mockStorage.saveYandexCookies(
            sessionId: 'sid-1',
            sessionId2: 'sid-2',
            loginToken: 'token-abc',
            yandexLogin: 'user@yandex.ru',
            yandexUid: 'uid-123',
          )).called(1);
    });
  });
}
