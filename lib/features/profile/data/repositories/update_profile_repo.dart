import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pakland/core/constants/api_constant.dart';

class UpdateProfileRepository {
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(ApiConstants.updateProfileUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Update profile failed: ${response.statusCode} - ${response.body}");
    }
  }
}