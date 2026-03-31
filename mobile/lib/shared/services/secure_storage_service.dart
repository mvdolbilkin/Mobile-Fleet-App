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


  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
