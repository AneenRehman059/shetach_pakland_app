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

      final hasPermission = await requestPermission();
      if (!hasPermission) {
        print('Storage permission denied');
        return false;
      }

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

      final directory = await getDownloadsDirectory();
      if (directory == null) {
        print('Could not get downloads directory');
        return false;
      }

      print('Download directory: ${directory.path}');

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final sanitizedFileName = sanitizeFileName(fileName);
      final file = File('${directory.path}/$sanitizedFileName.pdf');

      print('Saving to: ${file.path}');

      await file.writeAsBytes(bytes);

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
        final downloads = Directory('/storage/emulated/0/Download');

        if (!await downloads.exists()) {
          await downloads.create(recursive: true);
        }
        return downloads;
      } else if (Platform.isIOS) {
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
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
  }

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

  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;

      if (sdkVersion >= 33) {
        final status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      } else if (sdkVersion >= 29) {
        final status = await Permission.storage.request();
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }

    return true;
  }

  static Future<void> debugStorageInfo() async {
    print('=== STORAGE DEBUG INFO ===');

    final appDocDir = await getApplicationDocumentsDirectory();
    print('App Documents: ${appDocDir.path}');

    final externalDir = await getExternalStorageDirectory();
    print('External Storage: ${externalDir?.path}');

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