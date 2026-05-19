import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../repo/forgot_password_repo.dart';

class ForgotPasswordController extends GetxController {
  final _repo = ForgotPasswordRepository();
  final _storage = const FlutterSecureStorage();
  var isLoading = false.obs;

  Future<Map<String, dynamic>> updatePassword({
    required String cnic,
    required String password,
    required String mobileNo,
    required String emailAddress,
    required String userName,
  }) async {
    try {
      isLoading.value = true;

      final body = {
        "cnic": cnic,
        "password": password,
        "mobile_no": mobileNo,
        "email_address": emailAddress,
        "address": "string",
        "user_name": userName,
        "OTP": "",
        "otp_via": "sms",
        "deviceId": "string",
        "deviceModel": "string",
        "platform": "string",
        "osVersion": "string",
        "latitude": "string",
        "longitude": "string",
        "manufacturer": "string",
        "operatingSystem": "string",
        "webViewVersion": "string"
      };

      final response = await _repo.updatePassword(body);
      return response;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
