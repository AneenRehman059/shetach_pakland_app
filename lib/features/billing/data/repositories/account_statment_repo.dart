import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/billing/data/models/account_statement_model.dart';

class AccountStatementRepository {

  Future<AccountStatementResponse> getAccountStatement(AccountStatementRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.getAccountStatUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return AccountStatementResponse.fromJson(data);
      } else {
        throw Exception('Failed to load account statement: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load account statement: $e');
    }
  }
}