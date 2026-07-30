import 'package:flutter/material.dart';

class ScreenHelper {
  // TV/Wide screen detection — 750px+ width
  static bool isTV(BuildContext context) {
    return MediaQuery.of(context).size.width >= 750;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 750;
  }

  // Font sizes
  static double fontSize(BuildContext context, {required double mobile, required double tv}) {
    return isTV(context) ? tv : mobile;
  }

  // Padding
  static EdgeInsets padding(BuildContext context, {required EdgeInsets mobile, required EdgeInsets tv}) {
    return isTV(context) ? tv : mobile;
  }

  // Responsive value — any double
  static double value(BuildContext context, {required double mobile, required double tv}) {
    return isTV(context) ? tv : mobile;
  }
}