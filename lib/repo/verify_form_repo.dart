import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constant.dart';

class VerifyFormRepository {
  Future<Map<String, dynamic>> verifyForm(String formNo) async {
    final url = Uri.parse("${ApiConstants.formNoUrl}?form_no=$formNo");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        "Failed to verify form (code: ${response.statusCode}) - ${response.body}",
      );
    }
  }
}
