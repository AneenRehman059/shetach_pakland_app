// repositories/client_bill_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constant.dart';
import '../models/client_bill_model.dart';

class ClientBillRepository {
  Future<ClientBillModel> getClientBills({
    required String brnCode,
    required String idNo,
    required int fromMonth,
    required int toMonth,
    required int year,
  }) async {
    final url = Uri.parse(ApiConstants.clientBillsUrl);

    final Map<String, String> queryParams = {
      'brn_code': brnCode,
      'id_no': idNo,
      'from_month': fromMonth.toString(),
      'to_month': toMonth.toString(),
      'year': year.toString(),
    };

    final response = await http.get(
      url.replace(queryParameters: queryParams),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return ClientBillModel.fromJson(jsonResponse);
    } else {
      throw Exception(
        'Failed to load bills (code: ${response.statusCode}) - ${response.body}',
      );
    }
  }
}