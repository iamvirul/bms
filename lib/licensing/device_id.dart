import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';

// Returns a stable SHA-256 fingerprint of the device.
// The server HMAC-salts this with JWT_SECRET before storing it.
Future<String> computeDeviceId() async {
  final plugin = DeviceInfoPlugin();
  String raw;

  try {
    if (Platform.isAndroid) {
      final d = await plugin.androidInfo;
      raw = '${d.id}|${d.model}|${d.brand}|${d.product}';
    } else if (Platform.isIOS) {
      final d = await plugin.iosInfo;
      raw = '${d.identifierForVendor}|${d.model}|${d.systemName}';
    } else if (Platform.isWindows) {
      final d = await plugin.windowsInfo;
      raw = '${d.deviceId}|${d.computerName}|${d.userName}';
    } else if (Platform.isMacOS) {
      final d = await plugin.macOsInfo;
      raw = '${d.systemGUID ?? d.computerName}|${d.model}';
    } else if (Platform.isLinux) {
      final d = await plugin.linuxInfo;
      raw = '${d.machineId ?? d.id}|${d.prettyName}';
    } else {
      raw = 'unsupported-platform';
    }
  } catch (_) {
    raw = 'fallback-platform';
  }

  return sha256.convert(utf8.encode('bms-v1|$raw')).toString();
}
