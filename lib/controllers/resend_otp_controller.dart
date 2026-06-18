import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/models/signup_model.dart';
import 'package:pakland/view/signup_repo.dart';

import '../customs/toast_message.dart';
import '../login_screen.dart';
import '../verify_otp_screen.dart';

class ResendOtpController extends GetxController {
  var isLoading = false.obs;
  final _repo = SignUpRepository();
  String? phoneNumber;

  Future<void> resendOtp(BuildContext context, SignUpRequestModel model) async {
    try {
      isLoading.value = true;
      phoneNumber = model.mobileNo;
      final response = await _repo.signUp(model);

      if (response["StatusCode"] == "200") {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => VerifyOtpScreen(phoneNumber: model.mobileNo,userId: model.cnic,),
        //   ),
        // );

        // showTopSnackBar(context, "Signed up successfully.", Colors.green.withOpacity(0.7), icon: Icons.check_circle);
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
      // showTopSnackBar(context, e.toString(), Colors.red.withOpacity(0.7), icon: Icons.warning);
      print("Exception.");
    } finally {
      isLoading.value = false;
    }
  }
}