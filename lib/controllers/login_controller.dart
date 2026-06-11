import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../bottom_app_bar/bottom_app_bar.dart';
import '../customs/toast_message.dart';
import '../login_screen.dart';
import '../models/login_model.dart';
import '../models/sos_models.dart';
import '../repo/login_repo.dart';
import '../repo/sos_repo.dart';
import 'get_company_controller.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  final _repo = LoginRepository();
  final _storage = const FlutterSecureStorage();
  final CompanyController companyController = Get.put(CompanyController());
  final SOSRepository _sosRepo = SOSRepository();
  var userType = ''.obs;
  var lastStatusCode = ''.obs;

  final _profileUpdateController = StreamController<void>.broadcast();
  Stream<void> get onProfileUpdate => _profileUpdateController.stream;

  @override
  void onInit() {
    super.onInit();
    _loadUserTypeFromStorage();
  }

  Future<void> _loadUserTypeFromStorage() async {
    try {
      final storedUserType = await _storage.read(key: "user_type");
      if (storedUserType != null && storedUserType.isNotEmpty) {
        userType.value = storedUserType;
        print('✅ User type loaded from storage: ${userType.value}');
      } else {
        print('⚠️ No user type found in storage');
      }
    } catch (e) {
      print('❌ Error loading user type: $e');
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      final userId = await _storage.read(key: "user_id");
      return userId != null && userId.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  String getCurrentUserType() {
    return userType.value;
  }

  Future<bool> login({required String username, required String password, required String latitude, required String longitude, required String deviceId,required BuildContext context}) async {
    try {
      isLoading.value = true;

      final model = LoginRequestModel(username: username, password: password, latitude: latitude, longitude: longitude, deviceId: deviceId);
      final response = await _repo.login(model);

      lastStatusCode.value = response["StatusCode"]?.toString() ?? "";

      if (response["StatusCode"] == "200") {
        final obj = response["obj"];

        await _storage.write(key: "user_id", value: obj?["user_id"]?.toString() ?? "");
        await _storage.write(key: "user_name", value: obj?["user_name"]?.toString() ?? "");
        await _storage.write(key: "user_type", value: obj?["user_type"]?.toString() ?? "");
        await _storage.write(key: "email_no1", value: obj?["email_no1"]?.toString() ?? "");
        await _storage.write(key: "mobile_no1", value: obj?["mobile_no1"]?.toString() ?? "");
        await _storage.write(key: "OTP", value: obj?["OTP"]?.toString() ?? "");
        await _storage.write(key: "address", value: obj?["address"]?.toString() ?? "");
        await _storage.write(key: "profile_image_path", value: obj?["profile_image_path"]?.toString() ?? "");
        await _storage.write(key: "user_password", value: obj?["user_password"]?.toString() ?? "");

        userType.value = obj?["user_type"]?.toString() ?? "";

        Get.offAll(() => MainWrapper());
        await companyController.fetchAndStoreCompanyDetails("SHET");

        return true;

      } else if (response["StatusCode"] == "409") {
        // final message = response["Message"]?.toString() ?? "Access denied from this device.";
        // showTopSnackBar(
        //   context,
        //   title: "Access Denied",
        //   message,
        //   Colors.red.withOpacity(0.7),
        //   icon: Icons.warning,
        // );
        return false;

      }
      else if (response["StatusCode"] == "404") {
        final message = response["Message"]?.toString() ?? "Access denied from this device.";
        showTopSnackBar(
          context,
          title: "Access Denied",
          message,
          Colors.red.withOpacity(0.7),
          icon: Icons.warning,
        );
        return false;

      }
      else {
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void notifyProfileUpdated() {
    _profileUpdateController.add(null);
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      final userId = await _storage.read(key: "user_id");

      if (userId != null && userId.isNotEmpty) {
        try {
          final response = await _repo.logoutApi(userId);
          if (response["StatusCode"] == "200") {
            print('✅ Logout API called successfully');
          } else {
            print('⚠️ Logout API returned: ${response["Message"]}');
          }
        } catch (e) {
          print('❌ Logout API error: $e');
          // Continue logout even if API fails
        }

        if (userId != null && userId.isNotEmpty) {
          await _clearFCMToken(userId);
        }

        await _storage.delete(key: "fcm_token");
        await _storage.delete(key: "user_id");
        await _storage.delete(key: "user_name");
        await _storage.delete(key: "email_no1");
        await _storage.delete(key: "OTP");
        await _storage.delete(key: "address");
        await _storage.delete(key: "profile_image_path");
        await _storage.delete(key: "user_password");

        // Optional: Delete biometric data as well
        await _storage.delete(key: "biometric_enabled");
        await _storage.delete(key: "biometric_username");
        await _storage.delete(key: "biometric_password");

        // Clear user type
        userType.value = "";

        // Navigate to login screen
        Get.offAll(() => LoginScreen());

      }} catch (e) {
      print('❌ Error during logout: $e');
      // Even if there's an error, still navigate to login
      Get.offAll(() => LoginScreen());
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to clear FCM token from server
  Future<void> _clearFCMToken(String userId) async {
    try {
      print('🔄 Clearing FCM token for user: $userId');

      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();

      if (token != null && token.isNotEmpty) {

        final request = FCMTokenUpdateRequest(
          userId: userId,
          fcmToken: "",
        );

        final response = await _sosRepo.updateFCMToken(request);

        if (response["StatusCode"] == "200") {
          print('✅ FCM token cleared from server successfully');
        } else {
          print('⚠️ Failed to clear FCM token from server: ${response["Message"]}');
          showTopSnackBar(
            Get.context!,
            title: "Alert",
            "Some technical fault occured! Try again later.",
            Colors.red.withOpacity(0.7),
            icon: Icons.error,
          );
        }
      } else {
        print('⚠️ No FCM token found to clear');
      }

      // Also delete the token from Firebase
      await messaging.deleteToken();
      print('✅ FCM token deleted from Firebase');

    } catch (e) {
      print('❌ Error clearing FCM token: $e');
    }
  }

  @override
  void onClose() {
    _profileUpdateController.close();
    super.onClose();
  }
}