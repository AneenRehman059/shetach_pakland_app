import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/auth/presentation/controllers/login_controller.dart';
import 'package:pakland/features/dashboard/presentation/screens/main_screen.dart';
import 'package:pakland/features/recent_activity/presentation/screens/recent_activity_screen.dart';
import 'package:pakland/features/auth/presentation/screens/change_password_screen.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/core/controllers/theme_controller.dart';
import 'package:pakland/core/widgets/app_bar.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/feedback/presentation/screens/feedback_screen.dart';
import 'package:pakland/features/help_support/presentation/screens/help_support_screen.dart';
import 'package:pakland/features/profile/presentation/screens/personal_detail_screen.dart';
import 'package:pakland/features/faqs/presentation/screens/faqs_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final loginController = Get.find<LoginController>();
  final themeController = Get.find<ThemeController>();
  final Color menuBackgroundColor = AppColors.appColor;
  final storage = const FlutterSecureStorage();
  String? userName;
  String? email;
  String? profileImagePath;
  bool _isBiometricEnabled = false;
  StreamSubscription? _profileUpdateSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadBiometricState();

    _profileUpdateSubscription = loginController.onProfileUpdate.listen((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _profileUpdateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadBiometricState() async {
    final saved = await storage.read(key: "biometric_enabled");
    setState(() {
      _isBiometricEnabled = saved == "true";
    });
  }

  Future<void> _enableBiometricLogin() async {
    try {
      final LocalAuthentication auth = LocalAuthentication();

      final canCheck = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();
      if (!canCheck && !isSupported) {
        if (!mounted) return;
        showTopSnackBar(
          context,
          title: "Alert",
          "Biometric login is not supported on this device.",
          Colors.red.withOpacity(0.7),
          icon: Icons.error,
        );
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to enable biometric login',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate) {
        setState(() {
          _isBiometricEnabled = true;
        });
        await storage.write(key: "biometric_enabled", value: "true");
      } else {
        setState(() {
          _isBiometricEnabled = false;
        });
      }
    } catch (e) {
      debugPrint("Biometric error: $e");
      setState(() {
        _isBiometricEnabled = false;
      });
    }
  }

  Future<void> _disableBiometricLogin() async {
    setState(() {
      _isBiometricEnabled = false;
    });
    await storage.delete(key: "biometric_enabled");
  }

  Future<void> _loadUserData() async {
    String? name = await storage.read(key: "user_name");
    String? mail = await storage.read(key: "email_no1");
    String? imagePath = await storage.read(key: "profile_image_path");

    setState(() {
      userName = name ?? "Guest User";
      email = mail ?? "Not available";
      profileImagePath = imagePath;
    });
  }

  ImageProvider _getProfileImage() {
    if (profileImagePath == null || profileImagePath!.isEmpty) {
      return AssetImage(ImageConstant.user_profile);
    }

    if (profileImagePath!.startsWith('http')) {
      return NetworkImage(profileImagePath!);
    }

    return NetworkImage(
        '${ApiConstants.baseUrl}/${profileImagePath!.replaceAll('\\', '/')}');
  }

  void _showLogoutDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          width: screenWidth * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: screenHeight * 0.4,
          ),
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                ImageConstant.logout,
                height: screenHeight * 0.06,
                width: screenHeight * 0.06,
                fit: BoxFit.contain,
              ),
              SizedBox(height: screenHeight * 0.012),
              Text(
                "Logout",
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.008),
              Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                      onPressed: () async {
                        Get.back();
                        await loginController.logout();
                      },
                      child: Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isLargeScreen = screenWidth > 600;

    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Profile",
            style: TextStyle(
              color: AppColors.whiteBg,
              fontSize: isSmallScreen ? 18 : 20,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.appColor,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            // Profile Header Section
            Container(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.02,
                horizontal: screenWidth * 0.04,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: isLargeScreen
                        ? screenWidth * 0.08
                        : isSmallScreen
                        ? screenWidth * 0.15
                        : screenWidth * 0.12,
                    backgroundImage: _getProfileImage(),
                    onBackgroundImageError: (exception, stackTrace) {
                      setState(() {
                        profileImagePath = null;
                      });
                    },
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    userName ?? "Loading...",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 16 : 18,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    email ?? "Loading...",
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Menu Items Section
                    Container(
                      width: double.infinity,
                      color: menuBackgroundColor,
                      child: Column(
                        children: [
                          _buildMenuTile(
                            context: context,
                            onTap: () async {
                              final result = await Get.to(
                                      () => EditProfileScreen());
                              if (result == true) {
                                await _loadUserData();
                              }
                            },
                            imagePath: ImageConstant.detail,
                            title: 'Personal Details',
                          ),
                          const Divider(color: Colors.black38, height: 1),
                          _buildMenuTile(
                            context: context,
                            onTap: () {
                              Get.to(() => RecentActivityScreen());
                            },
                            imagePath: ImageConstant.history,
                            title: 'Recent Activity',
                          ),
                          const Divider(color: Colors.black38, height: 1),

                          _buildMenuTile(
                            context: context,
                            onTap: () {
                              Get.to(() => ChangePasswordScreen());
                            },
                            imagePath: ImageConstant.pass,
                            title: 'Change Password',
                          ),
                          const Divider(color: Colors.black38, height: 1),
                          _buildBiometricRow(context),
                          const Divider(color: Colors.black38, height: 1),
                          _buildMenuTile(
                            context: context,
                            onTap: () {
                              Get.to(() => HelpSupportScreen());
                            },
                            imagePath: ImageConstant.help,
                            title: 'Help & Feedback',
                          ),
                          const Divider(color: Colors.black38, height: 1),
                          // _buildMenuTile(
                          //   context: context,
                          //   onTap: () {
                          //     Get.to(() => FeedbackScreen());
                          //   },
                          //   imagePath: ImageConstant.feedback,
                          //   title: 'Feedback',
                          // ),
                          // Divider(color: Colors.black38, height: 1),
                          _buildMenuTile(
                            context: context,
                            onTap: () {
                              Get.to(() => FaqScreen());
                            },
                            imagePath: ImageConstant.faq,
                            title: 'FAQs',
                          ),
                          Divider(color: Colors.black38, height: 1),


                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Container(
                      width: double.infinity,
                      color: Theme.of(context).cardColor,
                      child: Column(
                        children: [
                          _buildMenuTile(
                            context: context,
                            onTap: () => _showLogoutDialog(context),
                            imagePath: ImageConstant.logout,
                            title: 'Logout',
                            textColor:
                            Theme.of(context).textTheme.bodyLarge!.color!,
                          ),
                          const Divider(color: Colors.black38, height: 1),
                          _buildMenuTile(
                            context: context,
                            onTap: () {
                              Get.dialog(
                                deleteAccountDialog(
                                  context: context,
                                  onDelete: () {

                                    debugPrint("Account deleted!");
                                  },
                                ),
                              );
                            },
                            imagePath: ImageConstant.delete,
                            title: 'Delete Account',
                            textColor:
                            Theme.of(context).textTheme.bodyLarge!.color!,
                          ),
                          const Divider(color: Colors.black38, height: 1),
                          SizedBox(height: screenHeight * 0.01),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    String? imagePath,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.012,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: isSmallScreen ? 1.5 : 2,
                ),
              ),
              child: Image.asset(
                imagePath!,
                height: isSmallScreen ? 20 : 22,
                width: isSmallScreen ? 20 : 22,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  color: textColor ?? Colors.white,
                  size: isSmallScreen ? 16 : 20,
                ),
          ],
        ),
      ),
    );
  }
  Widget _buildBiometricRow(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.012,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
                width: isSmallScreen ? 1.5 : 2,
              ),
            ),
            child: Image.asset(
              ImageConstant.fingerprint,
              height: isSmallScreen ? 20 : 22,
              width: isSmallScreen ? 20 : 22,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: screenWidth * 0.04),

          Expanded(
            child: Text(
              'Biometric Login',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: _isBiometricEnabled,
              activeColor: Colors.greenAccent,
              onChanged: (bool value) async {
                if (value) {
                  await _enableBiometricLogin();
                } else {
                  await _disableBiometricLogin();
                }
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget deleteAccountDialog({
    required BuildContext context,
    required VoidCallback onDelete,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        width: screenWidth * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: screenHeight * 0.45,
        ),
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_forever,
              size: screenHeight * 0.06,
              color: Colors.red,
            ),
            SizedBox(height: screenHeight * 0.012),
            Text(
              "Delete Account",
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.008),
            Text(
              "Are you sure you want to delete your account? This action cannot be undone.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      onDelete();
                    },
                    child: Text(
                      "Delete",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}