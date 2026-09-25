import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Get device identifier (MAC address alternative)
  static Future<String> getDeviceIdentifier() async {
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id; // ANDROID_ID
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'ios_unknown';
      }
      return 'web_or_unknown';
    } catch (e) {
      print('Error getting device identifier: $e');
      return 'error_unknown';
    }
  }

  // Get detailed device information
  static Future<Map<String, String>> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        return {
          'deviceId': androidInfo.id,
          'deviceModel': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'platform': 'android',
          'osVersion': androidInfo.version.release,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'hardware': androidInfo.hardware,
          'product': androidInfo.product,
        };
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return {
          'deviceId': iosInfo.identifierForVendor ?? 'unknown',
          'deviceModel': iosInfo.model,
          'manufacturer': 'Apple',
          'platform': 'ios',
          'osVersion': iosInfo.systemVersion,
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
        };
      }

      return {
        'deviceId': 'unknown',
        'deviceModel': 'unknown',
        'manufacturer': 'unknown',
        'platform': 'unknown',
        'osVersion': 'unknown',
      };
    } catch (e) {
      print('Error getting device info: $e');
      return {
        'deviceId': 'error_unknown',
        'deviceModel': 'error_unknown',
        'manufacturer': 'error_unknown',
        'platform': 'error_unknown',
        'osVersion': 'error_unknown',
      };
    }
  }

  // Get platform name
  static String getPlatform() {
    if (Platform.isAndroid) return "android";
    if (Platform.isIOS) return "ios";
    if (Platform.isWindows) return "windows";
    if (Platform.isMacOS) return "macos";
    if (Platform.isLinux) return "linux";
    return "web";
  }

  // Get operating system
  static String getOperatingSystem() {
    return Platform.operatingSystem;
  }
}