import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constant.dart';
import '../models/login_model.dart';

class LoginRepository {
  Future<Map<String, dynamic>> login(LoginRequestModel model) async {
    final response = await http.post(
      Uri.parse(ApiConstants.loginUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(model.toJson()),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> logoutApi(String userId) async {
    final uri = Uri.parse(ApiConstants.logoutUrl).replace(
      queryParameters: {"user_id": userId},
    );

    final response = await http.post(
      uri,
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Logout API failed: ${response.body}");
    }
  }
}