import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/sos/data/repositories/sos_repo.dart';
import 'package:pakland/core/services/video_background_service.dart';
import 'package:pakland/features/auth/presentation/screens/signup_screen.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/features/auth/presentation/controllers/login_controller.dart';
import 'package:pakland/core/services/biometric_auth_service.dart';
import 'package:pakland/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:flutter/services.dart';

import 'package:pakland/core/permissions/location_permission.dart';
import 'package:pakland/features/auth/presentation/controllers/send_otp_auth_device_controller.dart';
import 'package:pakland/core/widgets/biometric_button.dart';
import 'package:pakland/core/widgets/dialogs/biometric_dialogs.dart';
import 'package:pakland/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:pakland/core/services/get_device_info.dart';
import 'package:pakland/features/sos/data/models/sos_models.dart';

import '../../auth_widget/auth_wdget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with VideoSoundMixin<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final loginController = Get.put(LoginController());
  final sendOtpAuthDevController = Get.put(SendOtpAuthDeviceController());
  final biometricService = BiometricAuthService();
  final storage = const FlutterSecureStorage();
  final _sosRepo = SOSRepository();

  bool _isLoading = false;
  bool _isBiometricEnabled = false;
  bool _rememberMe = false;
  String? _savedBiometricUsername;
  final Map<String, String> _fieldErrors = {};
  bool _permissionRequested = false;

  final _videoService = VideoBackgroundService.instance;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _initBackgroundVideo();
  }

  void _initBackgroundVideo() {
    _videoService.initialize();
    _videoReady = _videoService.isReady;
    _videoService.controller.addListener(_onVideoUpdate);
  }

  void _onVideoUpdate() {
    final ready = _videoService.isReady;
    if (ready != _videoReady && mounted) {
      setState(() => _videoReady = ready);
    }
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

        BiometricDialogs.showBiometricUserMismatchDialog(
          context,
          _savedBiometricUsername,
          usernameController.text,
              () async {
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
      } else if (biometricService.lastError != null) {
        _showErrorSnackBar("Biometric unavailable", biometricService.lastError!);
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
                        try {
                          final response = await sendOtpAuthDevController.sendOtpAuthDevice(
                            cnic: usernameController.text,
                          );

                          if (response["StatusCode"] == "200") {
                            Future.delayed(const Duration(milliseconds: 1500), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VerifyOtpScreen(
                                    phoneNumber: "",
                                    isPasswordReset: true,
                                    userId: usernameController.text,
                                  ),
                                ),
                              );
                            });
                          } else {
                            showTopSnackBar(
                              context,
                              title: "Alert",
                              "Some technical fault occured! Try again later.",
                              Colors.red.withOpacity(0.7),
                              icon: Icons.warning,
                            );
                          }
                        } catch (e) {
                          showTopSnackBar(
                            context,
                            title: "Alert",
                            "Alert: ${e.toString()}",
                            Colors.red.withOpacity(0.7),
                            icon: Icons.warning,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8),

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
    if (_isBiometricEnabled &&
        !biometricService.isCurrentUserBiometricUser(
            usernameController.text,
            _savedBiometricUsername
        )) {
      BiometricDialogs.showBiometricHandlingDialog(
        context,
            () {
          _navigateToHome();
        },
            () async {
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

      final request = FCMTokenUpdateRequest(userId: userId, fcmToken: token);

      final response = await _sosRepo.updateFCMToken(request);

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
    _videoService.controller.removeListener(_onVideoUpdate);
    super.dispose();
  }

  void _clearError(String key) {
    if (_fieldErrors.containsKey(key)) {
      setState(() => _fieldErrors.remove(key));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: _videoReady
                ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoService.controller.value.size.width,
                height: _videoService.controller.value.size.height,
                child: VideoPlayer(_videoService.controller),
              ),
            )
                : Image.asset(
              ImageConstant.welcome,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AuthFadeSlide(
                            child: AuthHeader(
                              logoPath: ImageConstant.logo,
                              title: 'Welcome Back',
                              subtitle: 'Sign in to continue to your account',
                            ),
                          ),
                          const SizedBox(height: 26),
                          AuthGlassCard(
                            delayMs: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AuthTextField(
                                  controller: usernameController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  hintText: 'User ID',
                                  assetIcon: ImageConstant.authUser,
                                  errorText: _fieldErrors['cnic'],
                                  onChanged: (_) => _clearError('cnic'),
                                ),
                                const SizedBox(height: 16),
                                AuthTextField(
                                  controller: passwordController,
                                  textInputAction: TextInputAction.done,
                                  hintText: 'Password',
                                  assetIcon: ImageConstant.authLock,
                                  isPassword: true,
                                  maxLength: 20,
                                  errorText: _fieldErrors['password'],
                                  onChanged: (_) => _clearError('password'),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () => _saveRememberMeStatus(!_rememberMe),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: Checkbox(
                                                value: _rememberMe,
                                                onChanged: (bool? value) {
                                                  _saveRememberMeStatus(value ?? false);
                                                },
                                                checkColor: Colors.white,
                                                materialTapTargetSize:
                                                MaterialTapTargetSize.shrinkWrap,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                fillColor: MaterialStateProperty.resolveWith<Color>(
                                                      (Set<MaterialState> states) {
                                                    if (states.contains(MaterialState.selected)) {
                                                      return AppColors.iconColor;
                                                    }
                                                    return Colors.transparent;
                                                  },
                                                ),
                                                side: const BorderSide(color: Colors.white70, width: 1.5),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Remember me',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        minimumSize: const Size(0, 32),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
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
                                        'Forgot password?',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                AuthPrimaryButton(
                                  text: 'Sign In',
                                  onPressed: _isLoading ? () {} : () => _performLogin(),
                                ),
                                const SizedBox(height: 20),
                                const AuthOrDivider(),
                                const SizedBox(height: 8),
                                BiometricLoginButton(
                                  onPressed: _loginWithBiometric,
                                  isEnabled: _isBiometricEnabled,
                                  username: _savedBiometricUsername,
                                  size: 42,
                                ),
                                Center(
                                  child: Text(
                                    'Use fingerprint',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (!keyboardOpen)
                  AuthFadeSlide(delayMs: 240, child: _buildBottomSection()),
              ],
            ),
          ),

          if (_isLoading)
            Positioned.fill(
              child: Container(
                child: Center(
                  child: Lottie.asset(
                    'assets/images/loading.json',
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.0),
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomImageItem(
            imagePath: 'assets/images/help.png',
            label: 'Need Help?',
            onTap: () {
              showTopSnackBar(
                context,
                title: "Sign In",
                "You're already on the Sign In screen",
                Colors.blue.withOpacity(0.7),
                icon: Icons.info,
              );
            },
          ),
          _buildBottomImageItem(
            imagePath: 'assets/images/guest.png',
            label: 'Guest',
            onTap: () {
              Get.to(MainWrapper());
            },
          ),
          _buildBottomImageItem(
            imagePath: 'assets/images/log_out.png',
            label: 'Sign Up',
            onTap: () {
              Get.to(SignUpNScreen());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomImageItem({
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AuthGlassCircle(
          onTap: onTap,
          child: Image.asset(imagePath, height: 22, width: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}