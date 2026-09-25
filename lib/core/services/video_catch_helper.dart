import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class VideoCacheHelper {
  static Future<File> _localFile(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  /// Returns cached file if it already exists (instant, no network).
  static Future<File?> getCachedFileIfExists(String fileName) async {
    final file = await _localFile(fileName);
    if (await file.exists() && await file.length() > 0) {
      return file;
    }
    return null;
  }

  /// Downloads to a temp file first, then renames — avoids a
  /// half-written file being picked up if the app is killed mid-download.
  static Future<File?> download(String remoteUrl, String fileName) async {
    try {
      final target = await _localFile(fileName);
      final tempFile = await _localFile('$fileName.part');

      final request = http.Request('GET', Uri.parse(remoteUrl));
      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        return null;
      }

      final sink = tempFile.openWrite();
      await response.stream.pipe(sink);
      await sink.close();

      if (await target.exists()) {
        await target.delete();
      }
      await tempFile.rename(target.path);
      return target;
    } catch (e) {
      return null;
    }
  }
}