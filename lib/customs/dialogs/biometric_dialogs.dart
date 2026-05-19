import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/colors.dart';

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
    Get.dialog(
      AlertDialog(
        title: const Text('Biometric Login Not Enabled'),
        content: const Text(
            'Biometric is not enabled against this user id. '
                'Please enable biometric from User Profile.'
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
        child: Container(
          width: screenWidth * 0.85,
          padding: EdgeInsets.all(mediaQuery.size.width * 0.06),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(mediaQuery.size.width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.switch_account,
                  color: Colors.orange,
                  size: mediaQuery.size.width * 0.1,
                ),
              ),
              SizedBox(height: mediaQuery.size.height * 0.02),

              Text(
                'Different User Detected',
                style: TextStyle(
                  fontSize: mediaQuery.size.width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: mediaQuery.size.height * 0.015),

              Text(
                'You are logging in as a different user.\n\n'
                    'What would you like to do with the existing biometric login settings?',
                style: TextStyle(
                  fontSize: mediaQuery.size.width * 0.035,
                  color: const Color(0xFF4A4A4A),
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
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        'Keep Previous',
                        style: TextStyle(
                          color: Colors.grey.shade700,
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
                        backgroundColor: Colors.red,
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

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: screenWidth * 0.9,
          padding: EdgeInsets.all(screenWidth * 0.06),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fingerprint,
                  color: Colors.red,
                  size: screenWidth * 0.1,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              Text(
                'Biometric Login Failed',
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  'Biometric is not enabled for this User ID.',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: const Color(0xFF4A4A4A),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              Container(
                padding: EdgeInsets.all(screenWidth * 0.03),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: screenWidth * 0.05,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Text(
                        'Please enable biometric from your User Profile to use this feature.',
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              Container(
                height: 1,
                color: Colors.grey.shade200,
              ),
              SizedBox(height: screenHeight * 0.025),

              Text(
                'Do you want to disable the previous user\'s biometric login and continue?',
                style: TextStyle(
                  fontSize: screenWidth * 0.038,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2A2A2A),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.03),

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
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: screenWidth * 0.038,
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
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.018,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: screenWidth * 0.045,
                            color: AppColors.whiteBg,
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.01),

              Text(
                'This action will remove biometric login for the previous user',
                style: TextStyle(
                  fontSize: screenWidth * 0.028,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}