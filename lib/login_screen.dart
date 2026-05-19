import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:pakland/colors.dart';
import 'package:pakland/constants/image_constant.dart';
import 'package:pakland/customs/toast_message.dart';
import 'package:pakland/repo/sos_repo.dart';
import 'package:pakland/signup_screen.dart';
import 'package:pakland/bottom_app_bar/bottom_app_bar.dart';
import 'package:pakland/controllers/login_controller.dart';
import 'package:pakland/customs/custom_buttons.dart';
import 'package:pakland/customs/custom_fields.dart';
import 'package:pakland/services/biometric_auth_service.dart';

import 'app_permissions/location_permisson.dart';
import 'customs/biometric_button.dart';
import 'customs/dialogs/biometric_dialogs.dart';
import 'forgot_password_screen.dart';
import 'get_device_info.dart';
import 'models/sos_models.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final loginController = Get.put(LoginController());
  final biometricService = BiometricAuthService();
  final storage = const FlutterSecureStorage();
  final _sosRepo = SOSRepository();

  bool _isLoading = false;
  bool _isBiometricEnabled = false;
  bool _rememberMe = false;
  String? _savedBiometricUsername;
  final Map<String, String> _fieldErrors = {};
  bool _permissionRequested = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadRememberMeStatus();
    await _requestLocationPermission();
    await _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final state = await biometricService.loadBiometricState();
    if (!mounted) return;
    setState(() {
      _isBiometricEnabled = state['isEnabled'] as bool;
      _savedBiometricUsername = state['username'] as String?;
    });
  }

  Future<void> _requestLocationPermission() async {
    if (_permissionRequested) return;

    bool hasLocationPermission = await LocationPermissionService.isLocationPermissionGranted();
    if (hasLocationPermission) return;

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() => _permissionRequested = true);
      await LocationPermissionService.requestLocationPermission();
    }
  }

  Future<void> _loadRememberMeStatus() async {
    try {
      final String? rememberMe = await storage.read(key: "remember_me");
      setState(() => _rememberMe = rememberMe == "true");

      if (_rememberMe) {
        final credentials = await biometricService.loadSavedCredentials();
        if (credentials['username'] != null && credentials['password'] != null) {
          setState(() {
            usernameController.text = credentials['username']!;
            passwordController.text = credentials['password']!;
          });
        }
      }
    } catch (e) {
      print("Error loading remember me status: $e");
    }
  }

  Future<void> _saveRememberMeStatus(bool value) async {
    setState(() => _rememberMe = value);
    await storage.write(key: "remember_me", value: value.toString());

    if (!value) {
      await biometricService.clearAllBiometricData();
    }
  }

  Future<void> _loginWithBiometric() async {
    try {
      if (!_isBiometricEnabled) {
        BiometricDialogs.showBiometricNotEnabledDialog(context);
        return;
      }

      if (!biometricService.isCurrentUserBiometricUser(
          usernameController.text,
          _savedBiometricUsername
      )) {
        // Show single dialog that handles everything
        BiometricDialogs.showBiometricUserMismatchDialog(
          context,
          _savedBiometricUsername,
          usernameController.text,
              () async {
            // This will be called after user confirms
            await biometricService.clearAllBiometricData();
            setState(() {
              _isBiometricEnabled = false;
              _savedBiometricUsername = null;
            });
            _showSuccessSnackBar(
                "Biometric Disabled",
                "Previous user's biometric login has been disabled. Please login with your credentials."
            );
          },
        );
        return;
      }

      final didAuthenticate = await biometricService.authenticateWithBiometrics();

      if (didAuthenticate) {
        await _performLogin(isBiometric: true);
      }
    } catch (e) {
      _showErrorSnackBar("Biometric login failed", e.toString());
    }
  }

  Future<void> _performLogin({bool isBiometric = false}) async {
    if (!_validateFields()) return;

    setState(() => _isLoading = true);

    try {
      bool hasLocationPermission = await LocationPermissionService.isLocationPermissionGranted();
      if (!hasLocationPermission) {
        _showLocationPermissionError();
        return;
      }

      Position? userLocation = await LocationPermissionService.getCurrentPosition();
      if (userLocation == null) {
        _showLocationError();
        return;
      }

      // ✅ Get device ID before login
      final String deviceId = await DeviceInfoService.getDeviceIdentifier();

      bool isSuccess = await loginController.login(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        latitude: userLocation.latitude.toString(),
        longitude: userLocation.longitude.toString(),
        deviceId: deviceId,
        context: context
      );

      if (isSuccess) {
        await _handleSuccessfulLogin();
      } else if (loginController.lastStatusCode.value == "409") {
        _showDeviceConflictDialog();
      }
    } catch (e) {
      _showErrorSnackBar("Error", e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDeviceConflictDialog() {
    if (!mounted) return;
    setState(() => _isLoading = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              color: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: const [
                  Icon(Icons.phonelink_off_rounded, size: 44, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Session Conflict',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'This User ID is already logged in on another device.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'To continue here, the previous session will be logged out. Do you want to proceed?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Warning note
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.info_outline, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Logging out the other device will end any active operations on it.',
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout, size: 16),
                      label: const Text('Yes, logout other device'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        // TODO: call your backend force-logout API here,
                        // then retry login. Example:
                        await _performLogin();
                      },
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Cancel button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSuccessfulLogin() async {
    // Check if this is a different user than the biometric user
    if (_isBiometricEnabled &&
        !biometricService.isCurrentUserBiometricUser(
            usernameController.text,
            _savedBiometricUsername
        )) {
      BiometricDialogs.showBiometricHandlingDialog(
        context,
            () {
          // Keep previous biometric
          _navigateToHome();
        },
            () async {
          // Disable previous biometric
          await biometricService.clearAllBiometricData();
          setState(() {
            _isBiometricEnabled = false;
            _savedBiometricUsername = null;
          });
          await _syncFcmToken(usernameController.text.trim());
          _navigateToHome();
          _showSuccessSnackBar(
              "Biometric Reset",
              "Previous user's biometric login has been disabled"
          );
        },
      );
    } else {
      // Same user or no biometric
      if (_rememberMe) {
        await biometricService.saveBiometricCredentials(
          usernameController.text.trim(),
          passwordController.text.trim(),
        );
      }
      await _syncFcmToken(usernameController.text.trim());
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    setState(() => _isLoading = false);
    Get.offAll(() => MainWrapper());
  }

  bool _validateFields() {
    bool isValid = true;
    _fieldErrors.clear();

    if (usernameController.text.isEmpty) {
      _fieldErrors['cnic'] = 'Please enter your User ID';
      isValid = false;
    }
    if (passwordController.text.isEmpty) {
      _fieldErrors['password'] = 'Please enter password';
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  void _showLocationPermissionError() {
    setState(() => _isLoading = false);
    showTopSnackBar(
      context,
      title: "Location Permission Required",
      "Location permission is required to login",
      Colors.red.withOpacity(0.7),
      icon: Icons.location_off,
    );
  }

  void _showLocationError() {
    setState(() => _isLoading = false);
    showTopSnackBar(
      context,
      title: "Location Error",
      "Unable to get your location",
      Colors.red.withOpacity(0.7),
      icon: Icons.location_off,
    );
  }

  void _showErrorSnackBar(String title, String message) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    showTopSnackBar(
      context,
      title: title,
      message,
      Colors.red.withOpacity(0.7),
      icon: Icons.error,
    );
  }

  void _showSuccessSnackBar(String title, String message) {
    if (!mounted) return;
    showTopSnackBar(
      context,
      title: title,
      message,
      Colors.green,
      icon: Icons.check_circle,
    );
  }

  Future<void> _syncFcmToken(String userId) async {
    if (userId.isEmpty) return;

    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();

      if (token == null || token.isEmpty) {
        print('⚠️ FCM token not available for user $userId');
        return;
      }

      await storage.write(key: "fcm_token", value: token);

      // Creating request to send to the API
      final request = FCMTokenUpdateRequest(userId: userId, fcmToken: token);

      // Ensure the request data is sent correctly
      final response = await _sosRepo.updateFCMToken(request);

      // Handling the response
      if (response["StatusCode"] != '200') {
        print('⚠️ Failed to sync FCM token: ${response['Message']}');
      } else {
        print('✅ FCM token synced for user $userId');
      }
    } catch (e) {
      print('❌ Error syncing FCM token: $e');
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ImageConstant.sc),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 25),
                Image.asset(
                  ImageConstant.logo,
                  height: 120,
                  width: 120,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Sign in to your account to explore your dream place to live across the whole world',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // User ID Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              controller: usernameController,
                              keyboardType: TextInputType.text,
                              label: 'User ID',
                              labelStyle: TextStyle(color: AppColors.whiteBg),
                              hintText: 'Enter User Id',
                              imagePath: 'assets/images/cnic.png',
                              borderRadius: 30,
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            if (_fieldErrors.containsKey('cnic'))
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 4),
                                child: Text(
                                  _fieldErrors['cnic']!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Password Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              controller: passwordController,
                              label: 'Password',
                              labelStyle: TextStyle(color: AppColors.whiteBg),
                              hintText: 'Enter Password',
                              imagePath: 'assets/images/passwords.png',
                              obscureText: true,
                              showVisibilityIcon: true,
                              borderRadius: 30,
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            if (_fieldErrors.containsKey('password'))
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 4),
                                child: Text(
                                  _fieldErrors['password']!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // Remember Me and Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (bool? value) {
                                    _saveRememberMeStatus(value ?? false);
                                  },
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                      if (states.contains(MaterialState.selected)) {
                                        return Colors.red;
                                      }
                                      return Colors.transparent;
                                    },
                                  ),
                                  side: const BorderSide(color: Colors.white, width: 2),
                                ),
                                const Text(
                                  'Remember Me',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                if (usernameController.text.isEmpty) {
                                  showTopSnackBar(
                                    context,
                                    title: "Alert",
                                    "Please enter your User ID first",
                                    Colors.orange,
                                    icon: Icons.info,
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ForgotPasswordScreen(
                                        cnic: usernameController.text.trim(),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Forgot Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Sign In Button
                        Center(
                          child: CustomButton(
                            text: 'Sign In',
                            onPressed: _isLoading ? () {} : () => _performLogin(),
                            isLoading: _isLoading,
                            autoWidth: true,
                            borderRadius: 30,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                Get.to(SignUpNScreen());
                              },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(1, 2),
                                      blurRadius: 4,
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),

                        BiometricLoginButton(
                          onPressed: _loginWithBiometric,
                          isEnabled: _isBiometricEnabled,
                          username: _savedBiometricUsername,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}