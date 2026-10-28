import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';

class BiometricDialogs {
  static void showBiometricNotAvailableDialog(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    Get.dialog(
      AlertDialog(
        title: const Text('Biometric Not Available'),
        content: const Text(
            'Your device does not support biometric authentication or no biometrics are enrolled. '
                'Please set up fingerprint/face recognition in your device settings.'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showBiometricNotEnabledDialog(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: screenWidth * 0.85,
              padding: EdgeInsets.all(screenWidth * 0.06),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.fingerprint,
                      color: Colors.orange.shade300,
                      size: screenWidth * 0.1,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  Text(
                    'Biometric Not Enabled',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.015),

                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Text(
                      'Biometric login is not enabled for this User ID.',
                      style: TextStyle(
                        fontSize: screenWidth * 0.038,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade200,
                          size: screenWidth * 0.05,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Text(
                            'Please enable biometric from your User Profile to use this feature.',
                            style: TextStyle(
                              fontSize: screenWidth * 0.032,
                              color: Colors.blue.shade100,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        foregroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.018,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Got It',
                        style: TextStyle(
                          fontSize: screenWidth * 0.038,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void showBiometricHandlingDialog(
      BuildContext context,
      VoidCallback onKeepPrevious,
      VoidCallback onDisablePrevious,
      ) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: screenWidth * 0.85,
              padding: EdgeInsets.all(mediaQuery.size.width * 0.06),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(mediaQuery.size.width * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.switch_account,
                      color: Colors.orange.shade300,
                      size: mediaQuery.size.width * 0.1,
                    ),
                  ),
                  SizedBox(height: mediaQuery.size.height * 0.02),

                  Text(
                    'Different User Detected',
                    style: TextStyle(
                      fontSize: mediaQuery.size.width * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: mediaQuery.size.height * 0.015),

                  Text(
                    'You are logging in as a different user.\n\n'
                        'What would you like to do with the existing biometric login settings?',
                    style: TextStyle(
                      fontSize: mediaQuery.size.width * 0.035,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: mediaQuery.size.height * 0.03),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Get.back();
                            onKeepPrevious();
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: mediaQuery.size.height * 0.018,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.white.withOpacity(0.3)),
                            ),
                          ),
                          child: Text(
                            'Keep Previous',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: mediaQuery.size.width * 0.035,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: mediaQuery.size.width * 0.03),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            onDisablePrevious();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.85),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: mediaQuery.size.height * 0.018,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Disable',
                            style: TextStyle(
                              fontSize: mediaQuery.size.width * 0.035,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void showBiometricUserMismatchDialog(
      BuildContext context,
      String? savedUsername,
      String currentUsername,
      VoidCallback onDisableAndContinue,
      ) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final String saved =
    (savedUsername != null && savedUsername.trim().isNotEmpty)
        ? savedUsername.trim()
        : 'Not available';
    final String current =
    currentUsername.trim().isNotEmpty ? currentUsername.trim() : 'Not available';

    Widget userLine(String caption, String value) {
      return Row(
        children: [
          Text(
            '$caption  ',
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: screenWidth * 0.036,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: screenWidth * 0.85,
              constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
              padding: EdgeInsets.all(screenWidth * 0.06),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fingerprint,
                        color: Colors.orange.shade300,
                        size: screenWidth * 0.1,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    Text(
                      'Biometric Login Failed',
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Biometric is not enabled for this User ID.',
                            style: TextStyle(
                              fontSize: screenWidth * 0.038,
                              color: Colors.white.withOpacity(0.85),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.012),
                          Divider(
                            height: 1,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          SizedBox(height: screenHeight * 0.012),
                          userLine('Registered for', saved),
                          SizedBox(height: screenHeight * 0.006),
                          userLine('Signing in as', current),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade200,
                            size: screenWidth * 0.05,
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Expanded(
                            child: Text(
                              'Please enable biometric from your User Profile to use this feature.',
                              style: TextStyle(
                                fontSize: screenWidth * 0.032,
                                color: Colors.blue.shade100,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    Text(
                      'Do you want to disable the previous user\'s biometric login and continue?',
                      style: TextStyle(
                        fontSize: screenWidth * 0.036,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.92),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.018,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                    color: Colors.white.withOpacity(0.3)),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: screenWidth * 0.036,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              onDisableAndContinue();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.withOpacity(0.85),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.018,
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: screenWidth * 0.036,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.012),

                    Text(
                      'This will remove biometric login for the previous user.',
                      style: TextStyle(
                        fontSize: screenWidth * 0.029,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
