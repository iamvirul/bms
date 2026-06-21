import 'dart:convert';

import 'package:bms/licensing/license_constants.dart';
import 'package:bms/licensing/license_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LicenseService {
  LicenseService({
    FlutterSecureStorage? storage,
    http.Client? client,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _client = client ?? http.Client();

  final FlutterSecureStorage _storage;
  final http.Client _client;

  // Reads the persisted JWT and determines the current license state without
  // making any network call. Returns LicenseState.unlicensed if nothing is stored.
  Future<LicenseState> loadCachedState() async {
    final jwt = await _storage.read(key: kLicJwt);
    if (jwt == null) return LicenseState.unlicensed;

    final payload = _decodePayload(jwt);
    if (payload == null) {
      await clear();
      return LicenseState.unlicensed;
    }

    final expSeconds = payload['exp'];
    if (expSeconds is! int) {
      await clear();
      return LicenseState.unlicensed;
    }
    final exp = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000, isUtc: true);

    final tier     = _parseTier(payload['tier'] as String? ?? 'free');
    final features = _parseFeatures(payload['features']);

    if (exp.isAfter(DateTime.now().toUtc())) {
      return LicenseState(
        status: LicenseStatus.active,
        tier: tier,
        features: features,
        expiresAt: exp,
      );
    }

    // JWT expired — check offline grace period.
    final lastStr = await _storage.read(key: kLicLastValidated);
    if (lastStr != null) {
      DateTime last;
      try {
        last = DateTime.parse(lastStr);
      } catch (_) {
        await clear();
        return LicenseState.unlicensed;
      }
      final elapsed = DateTime.now().toUtc().difference(last);
      if (elapsed < kJwtGracePeriod) {
        return LicenseState(
          status: LicenseStatus.grace,
          tier: tier,
          features: features,
          expiresAt: exp,
          gracePeriodRemaining: kJwtGracePeriod - elapsed,
        );
      }
    }

    return LicenseState(
      status: LicenseStatus.expired,
      tier: tier,
      features: {},
      expiresAt: exp,
    );
  }

  // Activates with the given key and persists the resulting JWT.
  Future<LicenseState> activate(String key, String deviceId) async {
    final resp = await _client
        .post(
          Uri.parse('$kLicensingBaseUrl/v1/activate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'license_key': key.trim().toUpperCase(),
            'device_id': deviceId,
          }),
        )
        .timeout(const Duration(seconds: 20));

    final body = jsonDecode(resp.body) as Map<String, dynamic>;

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      final msg = (body['error'] as Map<String, dynamic>?)?['message']
          as String? ?? 'Activation failed';
      final code = (body['error'] as Map<String, dynamic>?)?['code'] as String?;
      throw LicenseException(msg, code);
    }

    final data = body['data'] as Map<String, dynamic>;
    final jwt  = data['token'] as String;
    await _persist(jwt);

    final tier     = _parseTier(data['tier'] as String? ?? 'free');
    final features = _parseFeatures(data['features']);
    return LicenseState(
      status: LicenseStatus.active,
      tier: tier,
      features: features,
    );
  }

  // Validates the stored JWT against the server and refreshes it.
  // On network failure, falls through to the cached grace-period state.
  Future<LicenseState> validateOnline(String jwt, String deviceId) async {
    try {
      final resp = await _client
          .post(
            Uri.parse('$kLicensingBaseUrl/v1/validate'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $jwt',
            },
            body: jsonEncode({'device_id': deviceId}),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(resp.body) as Map<String, dynamic>;

      if (resp.statusCode == 200) {
        final data    = body['data'] as Map<String, dynamic>;
        final newJwt  = data['token'] as String;
        await _persist(newJwt);
        return loadCachedState();
      }

      // Any 4xx means the server explicitly rejected the token — clear state.
      // Only preserve cached state for 5xx (server error) or network failure.
      if (resp.statusCode >= 400 && resp.statusCode < 500) {
        await clear();
        return LicenseState.unlicensed;
      }
    } catch (_) {
      // Network unavailable — fall through to cached grace-period state.
    }

    return loadCachedState();
  }

  // Deactivates this device slot on the server.
  Future<void> deactivate(String jwt, String deviceId) async {
    try {
      await _client
          .post(
            Uri.parse('$kLicensingBaseUrl/v1/deactivate'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $jwt',
            },
            body: jsonEncode({'device_id': deviceId}),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      // Best-effort; local clear happens regardless.
    }
    await clear();
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: kLicJwt),
      _storage.delete(key: kLicLastValidated),
      _storage.delete(key: kLicDeviceId),
    ]);
  }

  Future<String?> readStoredJwt() => _storage.read(key: kLicJwt);

  Future<void> _persist(String jwt) async {
    await Future.wait([
      _storage.write(key: kLicJwt, value: jwt),
      _storage.write(
          key: kLicLastValidated,
          value: DateTime.now().toUtc().toIso8601String()),
    ]);
  }

  static Map<String, dynamic>? _decodePayload(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;
      final padded = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(padded));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static LicenseTier _parseTier(String raw) => switch (raw) {
        'enterprise' => LicenseTier.enterprise,
        'pro'        => LicenseTier.pro,
        _            => LicenseTier.free,
      };

  static Set<String> _parseFeatures(dynamic raw) {
    if (raw is List) return raw.cast<String>().toSet();
    return {};
  }
}

class LicenseException implements Exception {
  const LicenseException(this.message, [this.code]);
  final String message;
  final String? code;

  @override
  String toString() => 'LicenseException($code): $message';
}
