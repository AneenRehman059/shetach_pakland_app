import 'dart:convert';
import 'dart:io';

/// Secure POST with SSL bypass (for development/testing)
Future<Map<String, dynamic>> securePost({
  required String url,
  Map<String, String>? headers,
  Map<String, dynamic>? body,
}) async {
  try {
    // Create HttpClient and bypass SSL
    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    // Create request
    final Uri uri = Uri.parse(url);
    final HttpClientRequest request = await httpClient.postUrl(uri);

    // Add headers
    headers?.forEach((key, value) {
      request.headers.set(key, value);
    });

    // Set JSON body if provided
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
    }

    // Send request and wait for response
    final HttpClientResponse response = await request.close();

    // Read the response body
    final String responseBody = await response.transform(utf8.decoder).join();

    // Close the client
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
