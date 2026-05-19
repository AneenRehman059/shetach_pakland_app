import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/colors.dart';
import '../bottom_app_bar/bottom_app_bar.dart';
import '../constants/image_constant.dart';

class CustomAppBar extends StatelessWidget {
  final double height;
  final bool showBackButton;
  final String? title;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    this.height = 66,
    this.showBackButton = true,
    this.title,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    final appBarHeight = height * (screenHeight / 812);
    final fontSize = screenWidth * 0.055;
    final logoHeight = screenHeight * 0.07;

    void handleBack() {
      // Navigate back to home screen
      Get.offAllNamed('/home');
    }

    return Container(
      color: AppColors.whiteBg,
      height: appBarHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showBackButton)
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: screenWidth * 0.06,
                  ),
                  onPressed: onBackPressed ?? handleBack,
                )
              else
                SizedBox(width: screenWidth * 0.12),

              Expanded(
                child: Center(
                  child: title != null
                      ? Text(
                    title!,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                      : Image.asset(
                    ImageConstant.logo,
                    height: logoHeight,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.12),
            ],
          ),
          const SizedBox(height: 8),
          Divider(
            height: 0,
            thickness: 1,
            color: AppColors.appColor,
          ),
        ],
      ),
    );
  }
}