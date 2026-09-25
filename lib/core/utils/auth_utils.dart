// lib/utils/auth_utils.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthUtils {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static Future<bool> isUserLoggedIn() async {
    try {
      final userId = await _storage.read(key: "user_id");
      return userId != null && userId.isNotEmpty;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  static Future<void> clearUserData() async {
    await _storage.delete(key: "user_id");
    await _storage.delete(key: "user_name");
    await _storage.delete(key: "user_type");
    await _storage.delete(key: "email_no1");
    await _storage.delete(key: "mobile_no1");
    await _storage.delete(key: "OTP");
    await _storage.delete(key: "address");
    await _storage.delete(key: "profile_image_path");
    await _storage.delete(key: "user_password");
  }
}