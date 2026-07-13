import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'function/screen_helper.dart';

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
    setState(() => appVersion = 'v${packageInfo.version}');
  }

  void _onHelpTap() {
    LoginCheckUtil.isUserLoggedIn().then((isLoggedIn) {
      if (isLoggedIn) {
        Get.to(HelpSupportScreen());
      } else {
        LoginCheckUtil.showLoginRequiredDialog(context, onYesPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final double paddingHorizontal = screenWidth * 0.05;

    final double logoSize = isTV ? screenHeight * 0.35 : (screenWidth > 600 ? 200 : 170);
    final double buttonFontSize = isTV ? 20 : (screenWidth > 600 ? 16 : 14);
    final double versionFontSize = isTV ? 18 : (screenWidth > 600 ? 16 : 14);
    final double largeButtonWidth = isTV ? screenWidth * 0.25 : (screenWidth > 600 ? 200 : screenWidth * 0.35);
    final double buttonVerticalPadding = isTV ? screenHeight * 0.025 : screenHeight * 0.015;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(child: Image.asset(ImageConstant.welcome, fit: BoxFit.cover)),
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.4))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.05, left: paddingHorizontal, right: paddingHorizontal),
                  child: Center(child: Image.asset(ImageConstant.logo, height: logoSize, width: logoSize)),
                ),

                const Spacer(),

                // Guest Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TVFocusButton(
                        label: 'GUEST',
                        width: largeButtonWidth * 1.2,
                        fontSize: buttonFontSize,
                        verticalPadding: buttonVerticalPadding,
                        isFilled: true,
                        isTV: isTV,
                        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainWrapper())),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                // Sign In / Sign Up
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TVFocusButton(
                        label: 'SIGN IN',
                        width: largeButtonWidth,
                        fontSize: buttonFontSize,
                        verticalPadding: buttonVerticalPadding,
                        isFilled: true,
                        isTV: isTV,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen())),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      _TVFocusButton(
                        label: 'SIGN UP',
                        width: largeButtonWidth,
                        fontSize: buttonFontSize,
                        verticalPadding: buttonVerticalPadding,
                        isFilled: true,
                        isTV: isTV,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpNScreen())),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                // Help, FAQs, Offices
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: _TVFocusButton(
                        label: 'HELP',
                        fontSize: buttonFontSize,
                        verticalPadding: buttonVerticalPadding,
                        isFilled: false,
                        isTV: isTV,
                        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                        onTap: _onHelpTap,
                      )),
                      Expanded(child: _TVFocusButton(
                        label: 'FAQS',
                        fontSize: buttonFontSize,
                        verticalPadding: buttonVerticalPadding,
                        isFilled: false,
                        isTV: isTV,
                        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                        onTap: _onHelpTap,
                      )),
                      Expanded(child: _TVFocusButton(
                        label: 'OFFICES',
                        fontSize: buttonFontSize,
                        verticalPadding: buttonVerticalPadding,
                        isFilled: false,
                        isTV: isTV,
                        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MainWrapper(initialIndex: 2))),
                      )),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                Center(child: Text(appVersion, style: TextStyle(color: Colors.white, fontSize: versionFontSize))),

                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// TV Focus Button — same design, focus highlight add
// ─────────────────────────────────────────
class _TVFocusButton extends StatefulWidget {
  final String label;
  final double? width;
  final double fontSize;
  final double verticalPadding;
  final bool isFilled;
  final bool isTV;
  final VoidCallback onTap;
  final EdgeInsets? margin;

  const _TVFocusButton({
    required this.label,
    this.width,
    required this.fontSize,
    required this.verticalPadding,
    required this.isFilled,
    required this.isTV,
    required this.onTap,
    this.margin,
  });

  @override
  State<_TVFocusButton> createState() => _TVFocusButtonState();
}

class _TVFocusButtonState extends State<_TVFocusButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    // Mobile — simple InkWell, koi focus nahi
    if (!widget.isTV) {
      return InkWell(
        onTap: widget.onTap,
        child: _buildContainer(focused: false),
      );
    }

    // TV — Focus widget with highlight
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isFocused ? 1.05 : 1.0,
          duration: Duration(milliseconds: 150),
          child: _buildContainer(focused: _isFocused),
        ),
      ),
    );
  }

  Widget _buildContainer({required bool focused}) {
    if (widget.isFilled) {
      return Container(
        width: widget.width,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: focused
              ? AppColors.appColor.withOpacity(0.8)
              : AppColors.appColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: focused ? Colors.white : AppColors.appColor,
            width: focused ? 2.0 : 1.0,
          ),
          boxShadow: focused
              ? [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)]
              : [],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: widget.verticalPadding),
        child: Center(
          child: Text(widget.label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: widget.fontSize,
              )),
        ),
      );
    }

    // Outline button
    return Container(
      width: widget.width,
      margin: widget.margin,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: widget.verticalPadding),
      decoration: BoxDecoration(
        border: Border.all(
          color: focused ? Colors.white : AppColors.appColor,
          width: focused ? 2.5 : 2.0,
        ),
        borderRadius: BorderRadius.circular(8),
        color: focused ? Colors.white.withOpacity(0.15) : Colors.transparent,
        boxShadow: focused
            ? [BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 10, spreadRadius: 1)]
            : [],
      ),
      child: Center(
        child: Text(widget.label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: widget.fontSize,
            )),
      ),
    );
  }
}