import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../customs/toast_message.dart';
import '../repo/update_profile_trpo.dart';
import 'login_controller.dart';

class UpdateProfileController extends GetxController {
  final RxBool isLoading = false.obs;
  final _repo = UpdateProfileRepository();
  final _storage = const FlutterSecureStorage();

  Future<bool> updateProfile({
    required BuildContext context,
    required String userName,
    required String mobileNo,
    required String emailAddress,
    required String address,
    String profileImagePath = "",
  }) async {
    try {
      isLoading.value = true;

      // Get stored values
      final userId = await _storage.read(key: "user_id") ?? "";
      final password = await _storage.read(key: "user_password") ?? "";
      final otp = await _storage.read(key: "OTP") ?? "";

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        "cnic": userId,
        "email_address": emailAddress,
        "user_name": userName,
        "father_name": "",
        "mobile_no": mobileNo,
        "country": "Pakistan",
        "city": "Lahore",
        "address": address,
        "password": password,
        "OTP": "",
        "profile_image_path": profileImagePath,
        "file_name": profileImagePath.isNotEmpty ? "profile.jpg" : "",
        "deviceId": "unknown",
        "deviceModel": "unknown",
        "platform": "Android",
        "osVersion": "unknown",
        "latitude": "0.0",
        "longitude": "0.0",
        "manufacturer": "unknown",
        "operatingSystem": "Android",
        "webViewVersion": "unknown"
      };

      if (profileImagePath.isEmpty) {
        requestBody.remove("profile_image_path");
        requestBody.remove("file_name");
      }

      final response = await _repo.updateProfile(requestBody);

      if (response["StatusCode"] == "200") {
        // Update all values in storage
        await Future.wait([
          _storage.write(key: "user_name", value: userName),
          _storage.write(key: "mobile_no1", value: mobileNo),
          _storage.write(key: "email_no1", value: emailAddress),
          _storage.write(key: "address", value: address),
        ]);

        // If profile image was updated, save the new path from the response
        if (profileImagePath.isNotEmpty && response["obj"] != null) {
          final updatedImagePath = response["obj"]["profile_image_path"]?.toString();
          if (updatedImagePath != null && updatedImagePath.isNotEmpty) {
            await _storage.write(key: "profile_image_path", value: updatedImagePath);
          }
        }

        // Notify all listeners about the profile update
        Get.find<LoginController>().notifyProfileUpdated();

        // Use showTopSnackBar instead of Get.snackbar
        showTopSnackBar(
          context,
          "User info updated successfully.",
          Colors.green.withOpacity(0.7),
          icon: Icons.check_circle,
        );

        return true;
      } else {
        // Use showTopSnackBar instead of Get.snackbar
        showTopSnackBar(
          context,
          title: "Alert",
          response["Message"] ?? "Update failed",
          Colors.red.withOpacity(0.7),
          icon: Icons.error,
        );
        return false;
      }
    } catch (e) {
      showTopSnackBar(
        context,
        title: "Alert",
        "Update failed: ${e.toString()}",
        Colors.red.withOpacity(0.7),
        icon: Icons.error,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}