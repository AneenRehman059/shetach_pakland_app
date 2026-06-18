import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pakland/constants/api_constant.dart';
import 'package:pakland/models/signup_model.dart';

class SignUpRepository {
  Future<Map<String, dynamic>> signUp(SignUpRequestModel model) async {
    final response = await http.post(
      Uri.parse(ApiConstants.signUpUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(model.toJson()),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return responseBody;
    } else if (response.statusCode == 201) {

      return {
        "StatusCode": "201",
        "Message": "User already exists",
        "Response": responseBody
      };
    } else {
      throw Exception("Failed to sign up: ${response.body}");
    }
  }
}