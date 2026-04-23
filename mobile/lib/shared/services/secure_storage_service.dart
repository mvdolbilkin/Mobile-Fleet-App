import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage());
});

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // Сохранение ключей Яндекс API
  Future<void> saveYandexCredentials({
    required String clid,
    required String apiKey,
    required String parkId,
  }) async {
    await _storage.write(key: 'clid', value: clid);
    await _storage.write(key: 'apiKey', value: apiKey);
    await _storage.write(key: 'parkId', value: parkId);
  }

  Future<String?> getClid() async {
    return await _storage.read(key: 'clid');
  }

  Future<String?> getApiKey() async {
    return await _storage.read(key: 'apiKey');
  }

  Future<String?> getParkId() async {
    return await _storage.read(key: 'parkId');
  }

  Future<void> deleteYandexCredentials() async {
    await _storage.delete(key: 'clid');
    await _storage.delete(key: 'apiKey');
    await _storage.delete(key: 'parkId');
  }

  // Сохранение Yandex cookies для авторизации через WebView
  Future<void> saveYandexCookies({
    required String sessionId,
    required String sessionId2,
    String? loginToken,
    String? yandexLogin,
    String? yandexUid,
  }) async {
    await _storage.write(key: 'yandex_session_id', value: sessionId);
    await _storage.write(key: 'yandex_session_id2', value: sessionId2);
    if (loginToken != null) {
      await _storage.write(key: 'yandex_login_token', value: loginToken);
    }
    if (yandexLogin != null) {
      await _storage.write(key: 'yandex_login', value: yandexLogin);
    }
    if (yandexUid != null) {
      await _storage.write(key: 'yandex_uid', value: yandexUid);
    }
  }

  Future<String?> getYandexSessionId() async {
    return await _storage.read(key: 'yandex_session_id');
  }

  Future<String?> getYandexSessionId2() async {
    return await _storage.read(key: 'yandex_session_id2');
  }

  Future<String?> getYandexLoginToken() async {
    return await _storage.read(key: 'yandex_login_token');
  }

  Future<String?> getYandexLogin() async {
    return await _storage.read(key: 'yandex_login');
  }

  Future<String?> getYandexUid() async {
    return await _storage.read(key: 'yandex_uid');
  }

  Future<void> deleteYandexCookies() async {
    await _storage.delete(key: 'yandex_session_id');
    await _storage.delete(key: 'yandex_session_id2');
    await _storage.delete(key: 'yandex_login_token');
    await _storage.delete(key: 'yandex_login');
    await _storage.delete(key: 'yandex_uid');
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
