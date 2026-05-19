// login_check_util.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../colors.dart';

class LoginCheckUtil {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static Future<bool> isUserLoggedIn() async {
    final userId = await _storage.read(key: "user_id");
    return userId != null && userId.isNotEmpty;
  }

  static Future<void> showLoginRequiredDialog(BuildContext context, {VoidCallback? onYesPressed}) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          backgroundColor: AppColors.lightAppColor,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? mediaQuery.size.width * 0.85 : 400,
            ),
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
            decoration: BoxDecoration(
              color: AppColors.lightAppColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image at the top
                Container(
                  height: isSmallScreen ? 80 : 100,
                  width: isSmallScreen ? 80 : 100,
                  decoration: BoxDecoration(
                    color: AppColors.appColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: isSmallScreen ? 40 : 50,
                    color: AppColors.whiteBg,
                  ),
                ),

                SizedBox(height: isSmallScreen ? 16 : 20),

                Text(
                  'Login Required',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteBg,
                  ),
                ),

                SizedBox(height: isSmallScreen ? 12 : 15),

                // Message
                Text(
                  'You need to be logged in to access this feature.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.white
                  ),
                ),

                SizedBox(height: isSmallScreen ? 4 : 5),

                Text(
                  'Do you want to login now?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: isSmallScreen ? 20 : 25),

                mediaQuery.size.width < 350
                    ? Column(
                  children: [
                    // No Button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.grey.shade100,
                        ),
                        child: Text(
                          'No',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    // Yes Button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (onYesPressed != null) {
                            onYesPressed();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:AppColors.appColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Yes',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // No Button
                    Expanded(
                      child: Container(
                        height: 45,
                        margin: const EdgeInsets.only(right: 8),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.grey.shade100,
                          ),
                          child: Text(
                            'No',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Yes Button
                    Expanded(
                      child: Container(
                        height: 45,
                        margin: const EdgeInsets.only(left: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (onYesPressed != null) {
                              onYesPressed();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.appColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Yes',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}