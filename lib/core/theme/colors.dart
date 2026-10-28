import 'package:flutter/material.dart';

class AppColors {
  static Color fromRGBA(int r, int g, int b, double opacity) {
    return Color.fromRGBO(r, g, b, opacity);
  }

  static final appColor = fromRGBA(31, 75, 89, 1);
  static final t1 = fromRGBA(30, 77, 96, 1);
  static final t2 = fromRGBA(191, 39, 47, 1);
  static final lightAppColor = fromRGBA(79, 139, 153, 1);
  static final btnColor = Color.fromRGBO(193, 39, 45, 0.7);
  static final iconColor = Color.fromRGBO(193, 39, 45, 1);
  static final softCorelRedColor = Color.fromRGBO(229, 115, 115, 1);
  static final bgColor = fromRGBA(236, 242, 255, 1);
  static final mediumGrey = fromRGBA(158, 158, 158, 1.0);
  static final darkGrey = fromRGBA(97, 97, 97, 1.0);
  static final whiteBg = fromRGBA(255, 255, 255, 1.0);
  static final black = fromRGBA(0, 0, 0, 1.0);
  static final grey = fromRGBA(217, 217, 217, 1);
  static final yellowColor = fromRGBA(255, 255, 0, 1.0);

  static final b1 = fromRGBA(141, 90, 186, 1.0);
  static final b2= fromRGBA(137, 22, 82, 1.0);
  static final b3 = fromRGBA(225, 120, 197, 1.0);

  static const Color appColorLight30 = Color(0xFF649CA9);

  static final primaryColor = appColor;
  static final primaryLightColor = fromRGBA(218, 62, 146, 1);
  static final primaryDarkColor = fromRGBA(154, 0, 84, 1);

  static final backgroundColor = fromRGBA(255, 255, 255, 1);
  static final surfaceColor = fromRGBA(255, 255, 255, 1);
  static final cardColor = fromRGBA(255, 255, 255, 1);

  static final textPrimaryColor = fromRGBA(255, 255, 255, 1);
  static final textSecondaryColor = fromRGBA(18, 18, 18, 1);
  static final textHintColor = primaryLightColor;
  static final textDisabledColor = fromRGBA(204, 153, 182, 1);
  static final blueGrey = fromRGBA(85, 116, 131,1);

  static final successColor = fromRGBA(81, 208, 131, 1);
  static final closeColor = fromRGBA(79, 116, 134, 1);
  static final warningColor = fromRGBA(252, 180, 27, 1);
  static final errorColor = fromRGBA(244, 104, 103, 1);
  static final infoColor = appColor;

  static final dividerColor = fromRGBA(230, 179, 207, 1);


  static final darkBackgroundColor = fromRGBA(18, 18, 18, 1);
  static final darkSurfaceColor = fromRGBA(30, 30, 30, 1);
  static final darkCardColor = fromRGBA(45, 45, 45, 1);
  static final darkDividerColor = fromRGBA(66, 66, 66, 1);
  static final darkTextPrimaryColor = fromRGBA(255, 255, 255, 1);
  static final darkTextSecondaryColor = fromRGBA(179, 179, 179, 1);
  static final darkTextHintColor = fromRGBA(102, 102, 102, 1);
  static final darkTextDisabledColor = fromRGBA(77, 77, 77, 1);

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return errorColor;
      case 'in progress':
        return warningColor;
      case 'closed':
        return closeColor;
      case 'done':
        return successColor;
      default:
        return mediumGrey;
    }
  }

  static Color priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.blue.shade200;
      case 'medium':
        return Colors.orange.shade200;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}