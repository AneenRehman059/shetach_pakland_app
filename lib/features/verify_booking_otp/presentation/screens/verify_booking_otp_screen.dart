import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/app_bar.dart';
import 'package:pakland/core/widgets/custom_buttons.dart';
import 'package:pakland/core/widgets/toast_message.dart';

import '../controllers/verify_booking_otp_controller.dart';

/// OTP screen for guest bookings (PlotBooking -> VerifyBookingOtp).
/// Same look as VerifyOtpForSignUpScreen.
class VerifyBookingOtpScreen extends StatefulWidget {
  /// Contact number entered on the BookingScreen (sent as `ContactNo`).
  final String contactNo;

  /// Same body that was sent to PlotBooking - reused for "Resend".
  final Map<String, dynamic> bookingPayload;

  const VerifyBookingOtpScreen({
    Key? key,
    required this.contactNo,
    required this.bookingPayload,
  }) : super(key: key);

  @override
  State<VerifyBookingOtpScreen> createState() => _VerifyBookingOtpScreenState();
}

class _VerifyBookingOtpScreenState extends State<VerifyBookingOtpScreen> {
  final TextEditingController otpController = TextEditingController();
  final _verifyController = Get.put(VerifyBookingOtpController());

  int _resendSeconds = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
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

  void _verifyOtp() {
    if (otpController.text.length != 4) {
      showTopSnackBar(context, title: "Alert",
          "Please enter a valid 4-digit OTP", Colors.black45);
      return;
    }
    _verifyController.verifyOtp(
      context,
      contactNo: widget.contactNo,
      otpCode: otpController.text,
    );
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;
    final ok =
    await _verifyController.resendOtp(context, widget.bookingPayload);
    if (ok && mounted) _startResendTimer();
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
                        "Verify OTP",
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),

                      Text(
                        "Enter the 4-digit code sent to\n${widget.contactNo}",
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
                          isLoading: _verifyController.isLoading.value,
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