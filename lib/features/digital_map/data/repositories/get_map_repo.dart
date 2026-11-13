import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:pakland/core/constants/api_constant.dart';

class DigitalMapRepo {
  Future<String> fetchMapWebView({
    required String branchCode,
    required String blockNo,
  }) async {
    final baseUri = Uri.parse(ApiConstants.getMapUrl);
    final uri = baseUri.replace(
      queryParameters: {
        ...baseUri.queryParameters,
        'brn_code': branchCode,
        'block_no': blockNo,
      },
    );
    final ioClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) =>
      host == ApiConstants.baseUrl.replaceAll('https://', '').replaceAll('/', '');

    final client = IOClient(ioClient);

    try {
      final response = await client
          .get(
        uri,
        headers: {
          'Accept': 'application/json, text/plain, */*',
        },
      )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final Map<String, dynamic> decoded =
      jsonDecode(response.body) as Map<String, dynamic>;
      final bool isError = decoded['error'] as bool? ?? true;
      final String statusCode = (decoded['StatusCode'] ?? '').toString();

      if (isError || statusCode != '200') {
        throw Exception(
          decoded['Message']?.toString() ?? 'Failed to load map',
        );
      }
      final String? html = decoded['obj'] as String?;

      if (html == null || html.trim().isEmpty) {
        throw Exception('Empty HTML in response');
      }

      return html;
    } finally {
      client.close();
    }
  }
}