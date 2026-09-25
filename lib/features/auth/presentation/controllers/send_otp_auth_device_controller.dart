import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:pakland/features/auth/data/repositories/forgot_password_repo.dart';

class SendOtpAuthDeviceController extends GetxController {
  final _repo = ForgotPasswordRepository();
  final _storage = const FlutterSecureStorage();
  var isLoading = false.obs;

  Future<Map<String, dynamic>> sendOtpAuthDevice({
    required String cnic,
  }) async {
    try {
      isLoading.value = true;

      final body = {
        "cnic": cnic,
        "password": "password",
        "mobile_no": "mobile_no",
        "email_address": "email_address",
        "address": "string",
        "user_name": "userName",
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

      final response = await _repo.sendOtpToAuthDev(body);
      print("~~~~~~~~~~~~~~~~~~~~~$response~~~~~~~~~~~~~~~~~~~~~~~~");
      return response;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}