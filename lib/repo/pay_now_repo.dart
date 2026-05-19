import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constant.dart';

class PaymentRepository {
  Future<Map<String, dynamic>> processPayment(Map<String, dynamic> body) async {
    final url = Uri.parse(ApiConstants.payNowUrl);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);

      if (decoded["StatusCode"] == "0") {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(decoded["Message"] ?? "Failed to load branches");
      }
    }
    else {
      throw Exception(
        "Failed to process payment (code: ${response.statusCode}) - ${response.body}",
      );
    }
  }
}