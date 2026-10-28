import 'package:flutter/material.dart';

class ScreenHelper {
  static const bool tabletUsesMobileDesign = true;

  static bool isTvDevice = false;

  static bool isTV(BuildContext context) {
    return isTvDevice;
  }

  static bool isMobile(BuildContext context) {
    return !isTvDevice;
  }

  static bool isTablet(BuildContext context) {
    if (tabletUsesMobileDesign || isTvDevice) return false;
    return MediaQuery.of(context).size.shortestSide > 600;
  }

  static double fontSize(BuildContext context, {required double mobile, required double tv}) {
    return isTV(context) ? tv : mobile;
  }

  static EdgeInsets padding(BuildContext context, {required EdgeInsets mobile, required EdgeInsets tv}) {
    return isTV(context) ? tv : mobile;
  }

  static double value(BuildContext context, {required double mobile, required double tv}) {
    return isTV(context) ? tv : mobile;
  }
}
