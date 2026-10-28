import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/auth/presentation/controllers/resend_otp_controller.dart';
import 'package:pakland/features/auth/presentation/controllers/verify_otp_controller.dart';
import 'package:pakland/core/widgets/app_bar.dart';
import 'package:pakland/core/widgets/custom_buttons.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/auth/data/models/signup_model.dart';

class VerifyOtpForSignUpScreen extends StatefulWidget {
  final String phoneNumber;
  final String userId;
  final bool isPasswordReset;
  final String password;
  final String otpVia;
  final String email;

  const VerifyOtpForSignUpScreen({
    Key? key,
    required this.phoneNumber,
    required this.userId,
    this.isPasswordReset = false,
    required this.password,
    required this.otpVia,
    required this.email,
  }) : super(key: key);

  @override
  State<VerifyOtpForSignUpScreen> createState() => _VerifyOtpForSignUpScreenState();
}

class _VerifyOtpForSignUpScreenState extends State<VerifyOtpForSignUpScreen> {
  TextEditingController otpController = TextEditingController();
  var isLoading = false.obs;
  final _signUpController = Get.put(VerifyOtpController());
  final _resendOtpController = Get.put(ResendOtpController());
  final _storage = const FlutterSecureStorage();
  String emailNo1 = "";
  String mobileNo1 = "";
  String userPassword = "";
  String userName = "";

  // Simple resend countdown so the "Resend" action feels intentional
  // rather than something that can be spammed.
  int _resendSeconds = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _loadStoredData();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendSeconds = 30;
    _canResend = false;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _resendSeconds--;
      });
      if (_resendSeconds <= 0) {
        setState(() => _canResend = true);
        return false;
      }
      return true;
    });
  }

  Future<void> _loadStoredData() async {
    try {
      emailNo1 = await _storage.read(key: "email_no1") ?? "";
      mobileNo1 = await _storage.read(key: "mobile_no1") ?? "";
      userName = await _storage.read(key: "user_name") ?? "";
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error loading stored data: $e");
    }
  }

  void _verifyOtp() async {
    if (otpController.text.length != 4) {
      showTopSnackBar(context, title:"Alert", "Please enter a valid 4-digit OTP", Colors.black45);
      return;
    }

    try {
      final signUpData = SignUpRequestModel(
        cnic: widget.userId,
        password: userPassword,
        mobileNo: widget.phoneNumber,
        emailAddress: "string",
        address: "lahore",
        userName: "string",
        otp: otpController.text,
        otpVia: widget.otpVia,
        deviceId: "string",
        deviceModel: "string",
        platform: "string",
        osVersion: "string",
        latitude: "string",
        longitude: "string",
        manufacturer: "string",
        operatingSystem: "string",
        webViewVersion: "string",
      );
      _signUpController.verifyOtpForSignupController(context,signUpData);
    } catch (e) {
      showTopSnackBar(context, "Invalid OTP. Please try again.", Colors.red.withOpacity(0.7),title:  "Alert",icon: Icons.warning);
    } finally {
      isLoading.value = false;
    }
  }

  void _resendOtp() {
    if (!_canResend) return;

    final signUpData = SignUpRequestModel(
      cnic: widget.userId,
      password: widget.password,
      mobileNo: widget.phoneNumber,
      emailAddress: widget.email,
      address: "lahore",
      userName: userName.isNotEmpty ? userName : "string",
      otp: "string",
      otpVia: widget.otpVia,
      deviceId: "string",
      deviceModel: "string",
      platform: "string",
      osVersion: "string",
      latitude: "string",
      longitude: "string",
      manufacturer: "string",
      operatingSystem: "string",
      webViewVersion: "string",
    );
    _resendOtpController.resendOtp(context, signUpData);
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final padding = mediaQuery.padding;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(showBackButton: true),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenHeight * 0.02,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: mediaQuery.size.height - padding.top - padding.bottom - kToolbarHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.05),
                      Icon(
                        Icons.lock_outline,
                        size: screenHeight * 0.08,
                        color: AppColors.appColor,
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      Text(
                        widget.isPasswordReset ? "Verify Password Reset" : "Verify OTP",
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),

                      Text(
                        widget.isPasswordReset
                            ? "Enter the 4-digit code to reset your password"
                            : "Enter the 4-digit code sent to\n${widget.phoneNumber}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.038,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),

                      PinCodeTextField(
                        appContext: context,
                        controller: otpController,
                        length: 4,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          fieldHeight: screenHeight * 0.06,
                          fieldWidth: screenWidth * 0.15,
                          activeFillColor: Colors.white,
                          inactiveFillColor: Colors.grey.shade100,
                          selectedFillColor: Colors.white,
                          activeColor: AppColors.appColor,
                          inactiveColor: Colors.grey.shade400,
                          selectedColor: AppColors.appColor,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        enableActiveFill: true,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      Obx(() => Center(
                        child: CustomButton(
                          text: 'Verify',
                          onPressed: _verifyOtp,
                          isLoading: _signUpController.isLoading.value,
                          autoWidth: true,
                          borderRadius: 30,
                        ),
                      )),
                      SizedBox(height: screenHeight * 0.02),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive the code? ",
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                          TextButton(
                            onPressed: _canResend ? _resendOtp : null,
                            child: Text(
                              _canResend ? "Resend" : "Resend in ${_resendSeconds}s",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _canResend
                                    ? AppColors.appColor
                                    : Colors.grey.shade400,
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.05),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}