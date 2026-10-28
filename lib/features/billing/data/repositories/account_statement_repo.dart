import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/billing/data/models/account_statement_model.dart';

class AccountStatementRepository {

  Future<AccountStatementResponse> getAccountStatement(AccountStatementRequest request) async {
    final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(ApiConstants.getAccountStatUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(request.toJson()),
          )
          .timeout(const Duration(seconds: 90));
    } on TimeoutException {
      throw Exception('Server took too long to respond. Please try again.');
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on HandshakeException catch (e) {
      throw Exception('Secure connection failed: ${e.message}');
    }

    if (response.statusCode != 200) {
      throw Exception('Server error ${response.statusCode}');
    }

    final body = utf8.decode(response.bodyBytes, allowMalformed: true).trim();
    final dynamic decoded;
    try {
      decoded = json.decode(body);
    } on FormatException {
      throw Exception('Invalid response from server');
    }
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected response from server');
    }
    return AccountStatementResponse.fromJson(decoded);
  }

  Future<String> getReceiptImageUrl({
    required String brnCode,
    required String receiptNo,
  }) async {
    try {
      final uri = Uri.parse(ApiConstants.getReceiptByReceiptNoUrl).replace(
        queryParameters: {
          'brn_code': brnCode,
          'receipt_no': receiptNo,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['error'] == false &&
            data['obj'] != null &&
            (data['obj'] as List).isNotEmpty) {
          final obj = data['obj'][0];
          String path = obj['Path'] ?? '';

          if (path.startsWith('~')) {
            path = path.substring(1);
          }

          path = path.replaceAll('\\', '/');

          if (!path.startsWith('/')) {
            path = '/$path';
          }

          return '${ApiConstants.baseUrl}$path';
        } else {
          throw Exception(data['Message'] ?? 'No receipt image found');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch receipt image: $e');
    }
  }
}