// Permission Service Class
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // This will show the system dialog
      final status = await Permission.storage.request();
      return status.isGranted;
    } else {
      // For iOS
      final status = await Permission.photos.request();
      return status.isGranted;
    }
  }

  static Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      return status.isGranted;
    } else {
      return await Permission.photos.status.isGranted;
    }
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}