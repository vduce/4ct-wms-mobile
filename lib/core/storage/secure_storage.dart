import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorageService>(
  (_) => const SecureStorageService(),
);

class SecureStorageService {
  const SecureStorageService();

  static const _storage = FlutterSecureStorage();

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) {
    return _storage.write(key: key, value: value);
  }

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> deleteMany(Iterable<String> keys) async {
    for (final key in keys) {
      await delete(key);
    }
  }
}
