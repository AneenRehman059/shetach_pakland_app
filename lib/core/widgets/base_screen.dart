import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pakland/core/controllers/theme_controller.dart';

class BaseScreen extends StatelessWidget {
  final Widget child;
  final Color statusBarColor;
  final Brightness statusBarBrightness;
  final Brightness statusBarIconBrightness;

  const BaseScreen({
    Key? key,
    required this.child,
    this.statusBarColor = Colors.grey,
    this.statusBarBrightness = Brightness.light,
    this.statusBarIconBrightness = Brightness.light,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: themeController.isDarkMode.value
            ? Colors.black
            : statusBarColor,
        statusBarIconBrightness: themeController.isDarkMode.value
            ? Brightness.light
            : statusBarIconBrightness,
        systemNavigationBarColor: themeController.isDarkMode.value
            ? Colors.black
            : Colors.white,
        systemNavigationBarIconBrightness: themeController.isDarkMode.value
            ? Brightness.light
            : Brightness.dark,
      ),
    );
    return child;
  }
}