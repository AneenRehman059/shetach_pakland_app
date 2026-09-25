import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:pakland/core/theme/colors.dart';

class ThemeController extends GetxController {
  /// Observables
  RxBool isDarkMode = false.obs;

  /// Toggle Theme
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    updateStatusBar();
  }

  /// Apply system status + navigation bar colors
  void updateStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColors.appColor, // Your default color
        statusBarIconBrightness:
        Brightness.light, // White icons for colored status bar

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
    updateStatusBar(); // Make sure it applies at startup
  }
}
