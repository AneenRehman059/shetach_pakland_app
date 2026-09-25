import 'package:permission_handler/permission_handler.dart' as ph;

class MicrophonePermissionService {
  // Check current microphone permission status
  static Future<ph.PermissionStatus> checkMicrophonePermission() async {
    try {
      return await ph.Permission.microphone.status;
    } catch (e) {
      print('Error checking microphone permission: $e');
      return ph.PermissionStatus.denied;
    }
  }

  // Request microphone permission
  static Future<ph.PermissionStatus> requestMicrophonePermission() async {
    try {
      return await ph.Permission.microphone.request();
    } catch (e) {
      print('Error requesting microphone permission: $e');
      return ph.PermissionStatus.denied;
    }
  }

  // Check if permission is granted
  static Future<bool> isMicrophonePermissionGranted() async {
    final status = await checkMicrophonePermission();
    return status.isGranted;
  }

  // Open app settings
  static Future<void> openAppSettings() async {
    try {
      await ph.openAppSettings();
    } catch (e) {
      print('Error opening app settings: $e');
    }
  }
}
