import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:pakland/core/theme/colors.dart';

class ThemeController extends GetxController {
  RxBool isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    updateStatusBar();
  }

  void updateStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColors.appColor,
        statusBarIconBrightness:
        Brightness.light,

        systemNavigationBarColor:
        isDarkMode.value ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness:
        isDarkMode.value ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    updateStatusBar();
  }
}
