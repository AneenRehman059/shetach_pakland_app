import 'package:get/get.dart';

import 'package:pakland/features/auth/data/repositories/communication_policy_repo.dart';

/// The 3 OTP methods the SignUp screen can show a radio button for.
enum OtpMethodOption { sms, email, whatsapp }

class CommunicationPolicyController extends GetxController {
  final _repo = CommunicationPolicyRepository();

  var isLoading = false.obs;

  /// Which single OTP method should be shown/selected on the SignUp screen.
  /// Defaults to `sms` until the API responds (or if it fails).
  var otpMethod = OtpMethodOption.sms.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCommunicationPolicy();
  }

  Future<void> fetchCommunicationPolicy() async {
    try {
      isLoading.value = true;
      final policy = await _repo.getCommunicationPolicy();

      final keyCode = policy.keyCode.trim().toLowerCase();

      if (keyCode == 'via_waba' || keyCode == 'whatsapp') {
        otpMethod.value = OtpMethodOption.whatsapp;
      } else if (keyCode == 'itel' || keyCode == 'telenor') {
        otpMethod.value = OtpMethodOption.sms;
      } else if (keyCode == 'email') {
        otpMethod.value = OtpMethodOption.email;
      } else {
        // Unknown key_code (e.g. via_ladder) - fall back to SMS.
        otpMethod.value = OtpMethodOption.sms;
      }
    } catch (e) {
      // On failure, keep default (sms) so the user can still sign up.
      print("Failed to fetch communication policy: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
