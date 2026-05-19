import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constant.dart';

class FeedbackRepository {

  Future<Map<String, dynamic>> sendFeedback(Map<String, dynamic> body) async {
    final url =   Uri.parse(ApiConstants.addFeedbackUrl);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        "Failed to send feedback (code: ${response.statusCode}) - ${response.body}",
      );
    }
  }
}
