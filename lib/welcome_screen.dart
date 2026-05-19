import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pakland/colors.dart';
import 'package:pakland/help_support_screen.dart';
import 'package:pakland/login_screen.dart';
import 'package:pakland/signup_screen.dart';
import 'bottom_app_bar/bottom_app_bar.dart';
import 'constants/image_constant.dart';
import 'customs/login_check_util.dart';
import 'dashboard/main_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = 'v${packageInfo.version}';
    });
  }

  void _onHelpTap() {
    LoginCheckUtil.isUserLoggedIn().then((isLoggedIn) {
      if (isLoggedIn) {
        Get.to(HelpSupportScreen());
      } else {
        LoginCheckUtil.showLoginRequiredDialog(
          context,
          onYesPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final double paddingHorizontal = screenWidth * 0.05;

    // Calculate button widths based on screen size
    final double largeButtonWidth = screenWidth > 600
        ? 200
        : screenWidth * 0.35;

    final double smallButtonWidth = screenWidth > 600
        ? 120
        : screenWidth * 0.28;

    // Responsive font sizes
    final double titleFontSize = screenWidth > 600 ? 24 : 18;
    final double buttonFontSize = screenWidth > 600 ? 16 : 14;
    final double versionFontSize = screenWidth > 600 ? 16 : 14;

    // Responsive logo size
    final double logoSize = screenWidth > 600 ? 200 : 170;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                ImageConstant.welcome,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.05,
                    left: paddingHorizontal,
                    right: paddingHorizontal,
                  ),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          ImageConstant.logo,
                          height: logoSize,
                          width: logoSize,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          "PakLand Housing",
                          style: TextStyle(
                            color: AppColors.whiteBg,
                            fontWeight: FontWeight.bold,
                            fontSize: titleFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                // Guest Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainWrapper(),
                            ),
                          );
                        },
                        child: Container(
                          width: largeButtonWidth * 1.2,
                          decoration: BoxDecoration(
                            color: AppColors.appColor.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.appColor,
                              width: 1.0,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: screenHeight * 0.015,
                          ),
                          child: Center(
                            child: Text(
                              'GUEST',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: buttonFontSize,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                // Sign In / Sign Up Buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: largeButtonWidth,
                          decoration: BoxDecoration(
                            color: AppColors.appColor.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.appColor,
                              width: 1.0,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: screenHeight * 0.015,
                          ),
                          child: Center(
                            child: Text(
                              'SIGN IN',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: buttonFontSize,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpNScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: largeButtonWidth,
                          decoration: BoxDecoration(
                            color: AppColors.appColor.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.appColor,
                              width: 1.0,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: screenHeight * 0.015,
                          ),
                          child: Center(
                            child: Text(
                              'SIGN UP',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: buttonFontSize,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                // Help, FAQS, Offices Buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _onHelpTap,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.01,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: screenHeight * 0.015,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.appColor,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                'HELP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: buttonFontSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: _onHelpTap,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.01,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: screenHeight * 0.015,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.appColor,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                'FAQS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: buttonFontSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MainWrapper(initialIndex: 2),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.01,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: screenHeight * 0.015,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.appColor,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                'OFFICES',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: buttonFontSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                // Version Text
                Center(
                  child: Text(
                    appVersion,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: versionFontSize,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ],
        ),
      ),
    );
  }
}