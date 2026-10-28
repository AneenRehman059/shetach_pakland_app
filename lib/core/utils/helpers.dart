import 'dart:convert';
import 'dart:io';

Future<Map<String, dynamic>> securePost({
  required String url,
  Map<String, String>? headers,
  Map<String, dynamic>? body,
}) async {
  try {
    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    final Uri uri = Uri.parse(url);
    final HttpClientRequest request = await httpClient.postUrl(uri);

    headers?.forEach((key, value) {
      request.headers.set(key, value);
    });

    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
    }

    final HttpClientResponse response = await request.close();

    final String responseBody = await response.transform(utf8.decoder).join();

    httpClient.close();

    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      throw Exception(
          "Request failed (${response.statusCode}): $responseBody");
    }
  } catch (e) {
    print("❌ securePost error: $e");
    rethrow;
  }
}
