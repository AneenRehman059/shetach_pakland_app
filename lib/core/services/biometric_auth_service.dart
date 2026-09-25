import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Storage keys
  static const String _biometricEnabledKey = "biometric_enabled";
  static const String _bioUsernameKey = "bio_username";
  static const String _bioPasswordKey = "bio_password";

  // Check if biometric is available on device
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();

      return canCheck && isSupported && availableBiometrics.isNotEmpty;
    } catch (e) {
      debugPrint("Error checking biometric availability: $e");
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint("Error getting biometrics: $e");
      return [];
    }
  }

  // Load biometric state from storage
  Future<Map<String, dynamic>> loadBiometricState() async {
    try {
      final String? enabled = await _storage.read(key: _biometricEnabledKey);
      final String? username = await _storage.read(key: _bioUsernameKey);

      return {
        'isEnabled': enabled == "true",
        'username': username,
      };
    } catch (e) {
      debugPrint("Error loading biometric state: $e");
      return {
        'isEnabled': false,
        'username': null,
      };
    }
  }

  // Save biometric credentials after successful login
  Future<void> saveBiometricCredentials(String username, String password) async {
    try {
      await _storage.write(key: _bioUsernameKey, value: username);
      await _storage.write(key: _bioPasswordKey, value: password);
    } catch (e) {
      debugPrint("Error saving biometric credentials: $e");
    }
  }

  // Enable biometric login
  Future<bool> enableBiometricLogin(String username, String password) async {
    try {
      await _storage.write(key: _biometricEnabledKey, value: "true");
      await saveBiometricCredentials(username, password);
      return true;
    } catch (e) {
      debugPrint("Error enabling biometric: $e");
      return false;
    }
  }

  // Disable biometric login
  Future<void> disableBiometricLogin() async {
    try {
      await _storage.delete(key: _biometricEnabledKey);
      await _storage.delete(key: _bioUsernameKey);
      await _storage.delete(key: _bioPasswordKey);
    } catch (e) {
      debugPrint("Error disabling biometric: $e");
    }
  }

  // Clear all biometric data
  Future<void> clearAllBiometricData() async {
    try {
      await _storage.delete(key: _biometricEnabledKey);
      await _storage.delete(key: _bioUsernameKey);
      await _storage.delete(key: _bioPasswordKey);
    } catch (e) {
      debugPrint("Error clearing biometric data: $e");
    }
  }

  // Authenticate with biometric
  Future<bool> authenticateWithBiometrics({String reason = 'Login to your account'}) async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      debugPrint("Biometric authentication error: $e");
      return false;
    }
  }

  // Check if current user matches biometric user
  bool isCurrentUserBiometricUser(String currentUsername, String? biometricUsername) {
    if (biometricUsername == null) return false;
    return currentUsername.trim() == biometricUsername;
  }

  // Load saved credentials for biometric login
  Future<Map<String, String?>> loadSavedCredentials() async {
    try {
      final String? username = await _storage.read(key: _bioUsernameKey);
      final String? password = await _storage.read(key: _bioPasswordKey);

      return {
        'username': username,
        'password': password,
      };
    } catch (e) {
      debugPrint("Error loading saved credentials: $e");
      return {
        'username': null,
        'password': null,
      };
    }
  }
}