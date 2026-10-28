import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/features/auth/data/models/signup_model.dart';
import 'package:pakland/features/auth/data/repositories/signup_repo.dart';
import 'package:pakland/features/auth/domain/usecases/signup_usecase.dart';

import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/auth/presentation/screens/login_screen.dart';
import 'package:pakland/features/auth/presentation/screens/verify_otp_screen.dart';

class ResendOtpController extends GetxController {
  var isLoading = false.obs;
  final SignUpUseCase _signUpUseCase = SignUpUseCase(SignUpRepository());
  String? phoneNumber;

  Future<void> resendOtp(BuildContext context, SignUpRequestModel model) async {
    try {
      isLoading.value = true;
      phoneNumber = model.mobileNo;
      final response = await _signUpUseCase(model);

      if (response["StatusCode"] == "200") {

        print("Signed up successfully.");
        return;
      }

      if (response["StatusCode"] == "201") {
        showTopSnackBar(context, "Account already exists!", Colors.red.withOpacity(0.7), icon: Icons.warning);
        print("Account already exists!");
        return;
      }

      if (response["StatusCode"] == "403") {
        showTopSnackBar(context, "Entered details do not match your existing booking information.", Colors.red.withOpacity(0.7), icon: Icons.warning);
        print("Entered details do not match your existing booking information.");
        return;
      }

    } catch (e) {
      print("Exception.");
    } finally {
      isLoading.value = false;
    }
  }
}