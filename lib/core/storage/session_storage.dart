import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// On web, window.crypto.subtle is unavailable in sandboxed/HTTP contexts.
// A POS app runs continuously on a dedicated device; in-memory web session is acceptable.
class SessionStorage {
  SessionStorage(this._secure);

  final FlutterSecureStorage _secure;

  static String? _webSession;

  Future<String?> read({required String key}) async {
    if (kIsWeb) return _webSession;
    return _secure.read(key: key);
  }

  Future<void> write({required String key, required String value}) async {
    if (kIsWeb) {
      _webSession = value;
      return;
    }
    await _secure.write(key: key, value: value);
  }

  Future<void> delete({required String key}) async {
    if (kIsWeb) {
      _webSession = null;
      return;
    }
    await _secure.delete(key: key);
  }
}
