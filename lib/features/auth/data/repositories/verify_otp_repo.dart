import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/auth/data/models/signup_model.dart';
import 'package:pakland/features/auth/domain/repositories/verify_otp_repository.dart';

class VerifyOtpRepo implements IVerifyOtpRepository {
  Future<Map<String, dynamic>> verifyOtp (SignUpRequestModel model) async {
    final response = await http.post(
      Uri.parse(ApiConstants.verifyOtpUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(model.toJson()),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }
}