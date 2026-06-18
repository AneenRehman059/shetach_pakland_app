import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pakland/models/signup_model.dart';
import 'package:pakland/view/signup_repo.dart';
import 'package:pakland/repo/verify_otp_repo.dart';
import 'package:pakland/repo/login_repo.dart';

import '../customs/toast_message.dart';
import '../login_screen.dart';
import '../verify_otp_screen.dart';

class VerifyOtpController extends GetxController {
  var isLoading = false.obs;
  final _repo = VerifyOtpRepo();
  final _loginRepo = LoginRepository();
  final _storage = const FlutterSecureStorage();
  String? phoneNumber;

  Future<void> verifyOtpController(BuildContext context, SignUpRequestModel model) async {
    try {
      isLoading.value = true;
      phoneNumber = model.mobileNo;
      final response = await _repo.verifyOtp(model);

      if (response["StatusCode"] == "200") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );

        // showTopSnackBar(context, "Otp Verify successfully.", Colors.green.withOpacity(0.7), icon: Icons.check_circle);
        showTopSnackBar(context, "Password updated successfully.", Colors.green.withOpacity(0.7), icon: Icons.check_circle);
        print("Signed up successfully.");
        return;
      }

      if (response["StatusCode"] == "201") {
        showTopSnackBar(context, "Otp already exists!", Colors.red.withOpacity(0.7), icon: Icons.warning);
        print("Account already exists!");
        return;
      }

      if (response["StatusCode"] == "403") {
        showTopSnackBar(context, "Otp not match.", Colors.red.withOpacity(0.7), icon: Icons.warning);
        print("Entered details do not match your existing booking information.");
        return;
      }

      // Handle any other status codes
      showTopSnackBar(context, "Unexpected response. Please try again.", Colors.red.withOpacity(0.7), icon: Icons.warning);

    } catch (e) {
      showTopSnackBar(context, "An error occurred. Please try again.", Colors.red.withOpacity(0.7), icon: Icons.warning);
      print("Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtpForSignupController(BuildContext context, SignUpRequestModel model) async {
    try {
      isLoading.value = true;
      phoneNumber = model.mobileNo;
      final response = await _repo.verifyOtp(model);

      if (response["StatusCode"] == "200") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );

        // showTopSnackBar(context, "Otp Verify successfully.", Colors.green.withOpacity(0.7), icon: Icons.check_circle);
        showTopSnackBar(context, "Signed up successfully.", Colors.green.withOpacity(0.7), icon: Icons.check_circle);
        print("Signed up successfully.");
        return;
      }

      if (response["StatusCode"] == "201") {
        showTopSnackBar(context, "Otp already exists!", Colors.red.withOpacity(0.7), icon: Icons.warning);
        print("Account already exists!");
        return;
      }

      if (response["StatusCode"] == "403") {
        showTopSnackBar(context, "Otp not match.", Colors.red.withOpacity(0.7), icon: Icons.warning);
        print("Entered details do not match your existing booking information.");
        return;
      }

      // Handle any other status codes
      showTopSnackBar(context, "Unexpected response. Please try again.", Colors.red.withOpacity(0.7), icon: Icons.warning);

    } catch (e) {
      showTopSnackBar(context, "An error occurred. Please try again.", Colors.red.withOpacity(0.7), icon: Icons.warning);
      print("Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

}