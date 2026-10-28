import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/auth/domain/repositories/update_password_repository.dart';

class UpdatePasswordRepository implements IUpdatePasswordRepository {
  Future<bool> updatePassword(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(ApiConstants.updatePasswordUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody == true;
    } else {
      throw Exception("Update failed: ${response.body}");
    }
  }
}