import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/help_support/presentation/screens/help_support_screen.dart';
import 'package:pakland/features/auth/presentation/screens/login_screen.dart';
import 'package:pakland/core/services/video_background_service.dart';
import 'package:pakland/features/auth/presentation/screens/signup_screen.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/core/utils/login_check_util.dart';
import 'package:pakland/features/dashboard/presentation/screens/main_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with VideoSoundMixin<WelcomeScreen> {
  String appVersion = '1.0.0';

  final _videoService = VideoBackgroundService.instance;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _getAppVersion();
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

  Future<void> _getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        appVersion = 'v${packageInfo.version}';
      });
    }
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
  void dispose() {
    _videoService.controller.removeListener(_onVideoUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final double paddingHorizontal = screenWidth * 0.05;

    final double largeButtonWidth = screenWidth > 600
        ? 200
        : screenWidth * 0.35;

    final double smallButtonWidth = screenWidth > 600
        ? 120
        : screenWidth * 0.28;

    final double titleFontSize = screenWidth > 600 ? 24 : 18;
    final double buttonFontSize = screenWidth > 600 ? 16 : 14;
    final double versionFontSize = screenWidth > 600 ? 16 : 14;

    final double logoSize = screenWidth > 600 ? 200 : 170;

    return SafeArea(
      child: Scaffold(
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