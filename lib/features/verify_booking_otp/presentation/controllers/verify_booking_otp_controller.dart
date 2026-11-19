import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/booking/data/repositories/booking_repo.dart';

class VerifyBookingOtpController extends GetxController {
  final BookingRepository _repo = BookingRepository();

  var isLoading = false.obs;
  var isResending = false.obs;

  String _clean(Object e) => e.toString().replaceFirst('Exception: ', '');


  Future<void> verifyOtp(
      BuildContext context, {
        required String contactNo,
        required String otpCode,
      }) async {
    try {
      isLoading.value = true;
      final ok = await _repo.verifyBookingOtp(
        contactNo: contactNo,
        otpCode: otpCode,
      );

      if (ok) {
        showTopSnackBar(
          context,
          title: "Success",
          "Your request submitted successfully.",
          Colors.green.withOpacity(0.7),
          icon: Icons.check_circle,
        );
        Get.offAll(() => MainWrapper());
      }
    } catch (e) {
      showTopSnackBar(
        context,
        title: "Alert",
        _clean(e),
        Colors.red.withOpacity(0.7),
        icon: Icons.warning,
      );
    } finally {
      isLoading.value = false;
    }
  }


  Future<bool> resendOtp(
      BuildContext context,
      Map<String, dynamic> bookingPayload,
      ) async {
    try {
      isResending.value = true;
      final ok = await _repo.plotBooking(bookingPayload);
      if (ok) {
        showTopSnackBar(
          context,
          title: "OTP Sent",
          "A new OTP has been sent.",
          Colors.green.withOpacity(0.7),
          icon: Icons.check_circle,
        );
      }
      return ok;
    } catch (e) {
      showTopSnackBar(
        context,
        title: "Alert",
        _clean(e),
        Colors.red.withOpacity(0.7),
        icon: Icons.warning,
      );
      return false;
    } finally {
      isResending.value = false;
    }
  }
}