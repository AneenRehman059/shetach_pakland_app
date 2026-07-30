import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/auth/domain/repositories/forgot_password_repository.dart';

class ForgotPasswordRepository implements IForgotPasswordRepository {
  Future<Map<String, dynamic>> updatePassword(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(ApiConstants.forgotPasswordUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Update failed: ${response.statusCode}");
    }
  }

  Future<Map<String, dynamic>> sendOtpToAuthDev(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(ApiConstants.sendOtpAuthDevrdUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Some technical fault occured! Try again later.");
    }
  }
}