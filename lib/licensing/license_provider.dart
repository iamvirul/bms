import 'dart:convert';

import 'package:bms/licensing/device_id.dart';
import 'package:bms/licensing/license_constants.dart';
import 'package:bms/licensing/license_model.dart';
import 'package:bms/licensing/license_service.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

// ---------------------------------------------------------------------------
// Service provider
// ---------------------------------------------------------------------------

final licenseServiceProvider = Provider<LicenseService>(
  (_) => LicenseService(),
);

// ---------------------------------------------------------------------------
// Device ID provider (cached in secure storage across restarts)
// ---------------------------------------------------------------------------

final deviceIdProvider = FutureProvider<String>((ref) async {
  const storage = FlutterSecureStorage();
  final cached = await storage.read(key: kLicDeviceId);
  if (cached != null) return cached;

  String id;
  try {
    id = await computeDeviceId();
  } catch (_) {
    // Unsupported platform or fingerprinting failure — generate a one-time
    // random ID stored locally so the same install always gets the same value.
    id = sha256.convert(utf8.encode(const Uuid().v4())).toString();
  }
  try {
    await storage.write(key: kLicDeviceId, value: id);
  } catch (_) {
    // Storage unavailable (e.g. web IndexedDB restrictions) — return in-memory
    // value; will recompute next session but won't block activation.
  }
  return id;
});

// ---------------------------------------------------------------------------
// License state notifier
// ---------------------------------------------------------------------------

class LicenseNotifier extends AsyncNotifier<LicenseState> {
  @override
  Future<LicenseState> build() async {
    final service = ref.watch(licenseServiceProvider);
    final cached  = await service.loadCachedState();

    // Start instantly from cache then silently refresh in the background.
    if (cached.isUsable) {
      _refreshInBackground(service);
      return cached;
    }

    return cached;
  }

  void _refreshInBackground(LicenseService service) {
    Future.microtask(() async {
      try {
        final jwt = await service.readStoredJwt();
        if (jwt == null) return;
        final deviceId = await ref.read(deviceIdProvider.future);
        final fresh    = await service.validateOnline(jwt, deviceId);
        state = AsyncData(fresh);
      } catch (_) {
        // Non-fatal — offline or transient failure; cached state remains.
      }
    });
  }

  // Called from ActivationScreen. Throws on failure so the screen can show
  // the error — never stores AsyncError in state.
  Future<void> activate(String key) async {
    state = const AsyncLoading();
    try {
      final service  = ref.read(licenseServiceProvider);
      final deviceId = await ref.read(deviceIdProvider.future);
      final result   = await service.activate(key, deviceId);
      state = AsyncData(result);
    } catch (e) {
      state = const AsyncData(LicenseState.unlicensed);
      rethrow;
    }
  }

  // Called from settings to release this device slot.
  // Always clears local state regardless of network/device-ID failures.
  Future<void> deactivate() async {
    try {
      final service  = ref.read(licenseServiceProvider);
      final jwt      = await service.readStoredJwt();
      if (jwt != null) {
        final deviceId = await ref.read(deviceIdProvider.future);
        await service.deactivate(jwt, deviceId);
      }
    } catch (_) {
      // Best-effort server call; local clear happens unconditionally below.
    }
    state = const AsyncData(LicenseState.unlicensed);
  }

  // Force an online re-validation (e.g. settings pull-to-refresh).
  Future<void> revalidate() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service  = ref.read(licenseServiceProvider);
      final jwt      = await service.readStoredJwt();
      if (jwt == null) return LicenseState.unlicensed;
      final deviceId = await ref.read(deviceIdProvider.future);
      return service.validateOnline(jwt, deviceId);
    });
  }
}

final licenseProvider = AsyncNotifierProvider<LicenseNotifier, LicenseState>(
  LicenseNotifier.new,
);

// ---------------------------------------------------------------------------
// Derived providers — consumed throughout the app
// ---------------------------------------------------------------------------

final allowedFeaturesProvider = Provider<Set<String>>((ref) {
  return ref.watch(licenseProvider).value?.features ?? {};
});

final licenseTierProvider = Provider<LicenseTier>((ref) {
  return ref.watch(licenseProvider).value?.tier ?? LicenseTier.free;
});

final licenseStatusProvider = Provider<LicenseStatus>((ref) {
  if (ref.watch(licenseProvider).isLoading) return LicenseStatus.checking;
  return ref.watch(licenseProvider).value?.status ?? LicenseStatus.unlicensed;
});
