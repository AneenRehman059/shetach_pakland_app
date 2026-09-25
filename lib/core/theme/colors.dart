// colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Convert RGBA to Flutter Color (RGBO)
  static Color fromRGBA(int r, int g, int b, double opacity) {
    return Color.fromRGBO(r, g, b, opacity);
  }

  // Define your color palette
  static final appColor = fromRGBA(31, 75, 89, 1); // #2196F3
  static final lightAppColor = fromRGBA(79, 139, 153, 1);
  static final btnColor = Color.fromRGBO(193, 39, 45, 0.7);
  static final iconColor = Color.fromRGBO(193, 39, 45, 1);
  static final softCorelRedColor = Color.fromRGBO(229, 115, 115, 1);
  static final bgColor = fromRGBA(236, 242, 255, 1);  // #F5F5F5
  static final mediumGrey = fromRGBA(158, 158, 158, 1.0); // #9E9E9E
  static final darkGrey = fromRGBA(97, 97, 97, 1.0);      // #616161
  static final whiteBg = fromRGBA(255, 255, 255, 1.0);      // #FFFFFF
  static final black = fromRGBA(0, 0, 0, 1.0);
  static final grey = fromRGBA(217, 217, 217, 1);
  static final yellowColor = fromRGBA(255, 255, 0, 1.0);

  static final b1 = fromRGBA(141, 90, 186, 1.0);
  static final b2= fromRGBA(137, 22, 82, 1.0);
  static final b3 = fromRGBA(225, 120, 197, 1.0);

  static const Color appColorLight30 = Color(0xFF649CA9);

  // Primary Brand Colors
  static final primaryColor = appColor; // Alias for consistency
  static final primaryLightColor = fromRGBA(218, 62, 146, 1); // #DA3E92
  static final primaryDarkColor = fromRGBA(154, 0, 84, 1); // #9A0054

  // Background Colors
  static final backgroundColor = fromRGBA(255, 255, 255, 1); // #FFFFFF
  static final surfaceColor = fromRGBA(255, 255, 255, 1); // #FFFFFF
  static final cardColor = fromRGBA(255, 255, 255, 1); // #FFFFFF

  // Text Colors
  static final textPrimaryColor = fromRGBA(255, 255, 255, 1); // White for brand backgrounds
  static final textSecondaryColor = fromRGBA(18, 18, 18, 1); // #121212 - Dark for light backgrounds
  static final textHintColor = primaryLightColor; // Light brand hint
  static final textDisabledColor = fromRGBA(204, 153, 182, 1);
  static final blueGrey = fromRGBA(85, 116, 131,1);// #CC99B6 - Muted brand

  // Status Colors
  static final successColor = fromRGBA(81, 208, 131, 1); // #51D083 - Green
  static final closeColor = fromRGBA(79, 116, 134, 1); // #51D083 - gray
  static final warningColor = fromRGBA(252, 180, 27, 1); // #FCB41B - Orange
  static final errorColor = fromRGBA(244, 104, 103, 1); // #F46867 - Red
  static final infoColor = appColor; // Same as primary

  static final dividerColor = fromRGBA(230, 179, 207, 1); // #E6B3CF - Light brand tint


  // Dark Theme Colors
  static final darkBackgroundColor = fromRGBA(18, 18, 18, 1); // #121212
  static final darkSurfaceColor = fromRGBA(30, 30, 30, 1); // #1E1E1E
  static final darkCardColor = fromRGBA(45, 45, 45, 1); // #2D2D2D
  static final darkDividerColor = fromRGBA(66, 66, 66, 1); // #424242
  static final darkTextPrimaryColor = fromRGBA(255, 255, 255, 1); // #FFFFFF
  static final darkTextSecondaryColor = fromRGBA(179, 179, 179, 1); // #B3B3B3
  static final darkTextHintColor = fromRGBA(102, 102, 102, 1); // #666666
  static final darkTextDisabledColor = fromRGBA(77, 77, 77, 1); // #4D4D4D

// Status Colors for Tickets/CMS
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