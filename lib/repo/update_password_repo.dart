import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pakland/constants/api_constant.dart';

class UpdatePasswordRepository {
  Future<bool> updatePassword(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(ApiConstants.updatePasswordUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      // Parse the response to check if it's true
      final responseBody = jsonDecode(response.body);
      return responseBody == true; // Direct boolean comparison
    } else {
      throw Exception("Update failed: ${response.body}");
    }
  }
}