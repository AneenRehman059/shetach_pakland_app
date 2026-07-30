
class ImageUrlHelper {
  ImageUrlHelper._();

  static String resolve(String path, String baseUrl) {
    if (path.isEmpty) return '';

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return _resolveIfDriveLink(path);
    }

    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl/$cleanPath';
  }

  static String _resolveIfDriveLink(String url) {
    if (!url.contains('drive.google.com')) return url;

    final match = RegExp(r'/d/([a-zA-Z0-9_-]+)').firstMatch(url);
    if (match != null) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=download&id=$fileId';
    }

    return url;
  }
}