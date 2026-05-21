import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pakland/models/signup_model.dart';
import 'package:pakland/repo/signup_repo.dart';
import 'package:pakland/repo/verify_otp_repo.dart';
import 'package:pakland/repo/login_repo.dart'; // ✅ Import login repo

import '../customs/toast_message.dart';
import '../login_screen.dart';
import '../verify_otp_screen.dart';

class VerifyOtpForloginauthController extends GetxController {
  var isLoading = false.obs;
  final _repo = VerifyOtpRepo();
  final _loginRepo = LoginRepository(); // ✅ Add login repo
  final _storage = const FlutterSecureStorage(); // ✅ Add storage
  String? phoneNumber;

  Future<void> verifyOtpLoginAuthController(BuildContext context, SignUpRequestModel model) async {
    try {
      isLoading.value = true;
      phoneNumber = model.mobileNo;
      final response = await _repo.verifyOtp(model);

      if (response["StatusCode"] == "200") {
        // ✅ Call logout API before navigating to LoginScreen
        try {
          final userId = await _storage.read(key: "user_id");
          if (userId != null && userId.isNotEmpty) {
            final logoutResponse = await _loginRepo.logoutApi(userId);
            if (logoutResponse["StatusCode"] == "200") {
              print("✅ Logout API called successfully after OTP verification.");
            } else {
              print("⚠️ Logout API warning: ${logoutResponse["Message"]}");
            }
          }
        } catch (e) {
          print("❌ Logout API error (non-blocking): $e");
          // Non-blocking — continue navigation even if logout API fails
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );

        showTopSnackBar(
          context,
          "Otp Verify successfully.",
          Colors.green.withOpacity(0.7),
          icon: Icons.check_circle,
        );
        print("Signed up successfully.");
        return;
      }

      if (response["StatusCode"] == "201") {
        showTopSnackBar(context, "Otp already exists!", Colors.red.withOpacity(0.7), icon: Icons.warning);
        return;
      }

      if (response["StatusCode"] == "403") {
        showTopSnackBar(context, "Email/Mobile No. not exist!", Colors.red.withOpacity(0.7), icon: Icons.warning);
        return;
      }

      showTopSnackBar(context, "Unexpected response. Please try again.", Colors.red.withOpacity(0.7), icon: Icons.warning);

    } catch (e) {
      showTopSnackBar(context, "An error occurred. Please try again.", Colors.red.withOpacity(0.7), icon: Icons.warning);
      print("Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }
}