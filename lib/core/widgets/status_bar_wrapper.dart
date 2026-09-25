import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/controllers/theme_controller.dart';

class StatusBarWrapper extends StatelessWidget {
  final Widget child;

  const StatusBarWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColors.appColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: themeController.isDarkMode.value
            ? AppColors.appColor
            : Colors.white,
        systemNavigationBarIconBrightness: themeController.isDarkMode.value
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return child;
  }
}
