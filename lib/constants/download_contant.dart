import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class DownloadUtils {
  static Future<bool> downloadFile(String url, String fileName) async {
    try {
      print('Starting download: $fileName');

      // Request appropriate permissions
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        print('Storage permission denied');
        return false;
      }

      // Download the file
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        print('HTTP Error: ${response.statusCode}');
        return false;
      }

      final bytes = response.bodyBytes;
      if (bytes.isEmpty) {
        print('Empty file downloaded');
        return false;
      }

      // Get the correct directory
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        print('Could not get downloads directory');
        return false;
      }

      print('Download directory: ${directory.path}');

      // Create directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Create file with proper extension
      final sanitizedFileName = sanitizeFileName(fileName);
      final file = File('${directory.path}/$sanitizedFileName.pdf');

      print('Saving to: ${file.path}');

      // Write file
      await file.writeAsBytes(bytes);

      // Verify file was created
      final exists = await file.exists();
      final size = exists ? await file.length() : 0;

      print('File exists: $exists');
      print('File size: $size bytes');

      return exists && size > 0;
    } catch (e) {
      print("Download error: $e");
      return false;
    }
  }

  static Future<Directory?> getDownloadsDirectory() async {
    try {
      if (Platform.isAndroid) {
        // Public Downloads directory ka path
        final downloads = Directory('/storage/emulated/0/Download');

        if (!await downloads.exists()) {
          await downloads.create(recursive: true);
        }
        return downloads;
      } else if (Platform.isIOS) {
        // iOS mein Documents folder use karna parega
        return await getApplicationDocumentsDirectory();
      }
      return null;
    } catch (e) {
      print("Error getting Downloads directory: $e");
      return await getApplicationDocumentsDirectory();
    }
  }


  static Future<bool> _isScopedStorage() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 29;
    }
    return false;
  }

  static String sanitizeFileName(String name) {
    // Remove invalid characters and replace spaces with underscores
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'_+'), '_') // Replace multiple underscores with single
        .trim();
  }

  // Check if file exists
  static Future<bool> checkFileExists(String fileName) async {
    try {
      final directory = await getDownloadsDirectory();
      if (directory == null) return false;

      final sanitizedFileName = sanitizeFileName(fileName);
      final file = File('${directory.path}/$sanitizedFileName.pdf');

      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Request appropriate permissions based on Android version
  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;

      if (sdkVersion >= 33) {
        // Android 13+ - need READ_MEDIA_IMAGES or READ_MEDIA_VIDEO
        final status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      } else if (sdkVersion >= 29) {
        // Android 10-12 - need storage permission
        final status = await Permission.storage.request();
        return status.isGranted;
      } else {
        // Android <10 - need storage permission
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      // iOS - request photos permission
      final status = await Permission.photos.request();
      return status.isGranted;
    }

    return true; // For other platforms, assume permission is granted
  }

  // Debug method to check storage info
  static Future<void> debugStorageInfo() async {
    print('=== STORAGE DEBUG INFO ===');

    // App's private directory
    final appDocDir = await getApplicationDocumentsDirectory();
    print('App Documents: ${appDocDir.path}');

    // External storage
    final externalDir = await getExternalStorageDirectory();
    print('External Storage: ${externalDir?.path}');

    // Check if we can access public Downloads
    try {
      final possiblePaths = [
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Downloads',
        '/sdcard/Download',
        '/sdcard/Downloads',
      ];

      for (var path in possiblePaths) {
        final dir = Directory(path);
        final exists = await dir.exists();
        print('$path exists: $exists');
        if (exists) {
          try {
            final files = dir.listSync();
            print('Files in $path: ${files.length}');
          } catch (e) {
            print('Cannot list files in $path: $e');
          }
        }
      }
    } catch (e) {
      print('Error checking paths: $e');
    }
  }
}