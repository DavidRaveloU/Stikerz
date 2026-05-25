import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Utility service to collect basic device and app information.
///
/// This is used for diagnostics and support workflows where a concise
/// summary of the runtime environment is required (platform, model,
/// OS version, and app build/version).
class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Returns the app version in the format `version+buildNumber`.
  ///
  /// Returns `'Unknown'` if package metadata cannot be read.
  static Future<String> _getAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return '${info.version}+${info.buildNumber}';
    } catch (_) {
      return 'Unknown';
    }
  }

  /// Collects a small map of device attributes useful for diagnostics.
  ///
  /// Keys vary by platform. On Android we return manufacturer, model,
  /// brand, device, android version, SDK level and security patch. On iOS
  /// we return model, system name, system version and device name. The
  /// returned map always includes `App Version` when available.
  static Future<Map<String, String>> getDeviceInfo() async {
    try {
      final appVersion = await _getAppVersion();

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'Manufacturer': androidInfo.manufacturer,
          'Model': androidInfo.model,
          'Brand': androidInfo.brand,
          'Device': androidInfo.device,
          'Android Version': androidInfo.version.release,
          'SDK': androidInfo.version.sdkInt.toString(),
          'Security Patch': androidInfo.version.securityPatch ?? 'N/A',
          'App Version': appVersion,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'Model': iosInfo.model,
          'System Name': iosInfo.systemName,
          'System Version': iosInfo.systemVersion,
          'Device Name': iosInfo.name,
          'App Version': appVersion,
        };
      }
      return {};
    } catch (e) {
      return {'Error': 'Failed to get device info: $e'};
    }
  }

  /// Formats `getDeviceInfo()` output into a readable multi-line string.
  static String formatDeviceInfo(Map<String, String> info) {
    return info.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }
}
