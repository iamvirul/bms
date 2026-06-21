import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

// Returns a stable SHA-256 fingerprint of the device.
// The server HMAC-salts this with JWT_SECRET before storing it.
Future<String> computeDeviceId() async {
  final plugin = DeviceInfoPlugin();
  String raw;

  try {
    if (kIsWeb) {
      final d = await plugin.webBrowserInfo;
      raw = '${d.browserName.name}|${d.platform ?? 'web'}|${d.vendor ?? ''}';
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final d = await plugin.androidInfo;
          raw = '${d.id}|${d.model}|${d.brand}|${d.product}';
        case TargetPlatform.iOS:
          final d = await plugin.iosInfo;
          raw = '${d.identifierForVendor}|${d.model}|${d.systemName}';
        case TargetPlatform.windows:
          final d = await plugin.windowsInfo;
          raw = '${d.deviceId}|${d.computerName}|${d.userName}';
        case TargetPlatform.macOS:
          final d = await plugin.macOsInfo;
          raw = '${d.systemGUID ?? d.computerName}|${d.model}';
        case TargetPlatform.linux:
          final d = await plugin.linuxInfo;
          raw = '${d.machineId ?? d.id}|${d.prettyName}';
        case TargetPlatform.fuchsia:
          raw = 'fuchsia-unsupported';
      }
    }
  } catch (_) {
    raw = 'fallback-platform';
  }

  return sha256.convert(utf8.encode('bms-v1|$raw')).toString();
}
