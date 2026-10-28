import 'package:get/get.dart';

import 'package:pakland/features/auth/data/repositories/communication_policy_repo.dart';
import 'package:pakland/features/auth/domain/usecases/communication_policy_usecase.dart';

/// The 3 OTP methods the SignUp / Forgot Password screens can show.
enum OtpMethodOption { sms, email, whatsapp }

/// Value sent to the API (`otp_via`) and label shown on screen.
extension OtpMethodOptionX on OtpMethodOption {
  String get value {
    if (this == OtpMethodOption.whatsapp) return 'whatsapp';
    if (this == OtpMethodOption.email) return 'email';
    return 'sms';
  }

  String get label {
    if (this == OtpMethodOption.whatsapp) return 'WHATSAPP';
    if (this == OtpMethodOption.email) return 'EMAIL';
    return 'SMS';
  }
}

class CommunicationPolicyController extends GetxController {
  final CommunicationPolicyUseCase _communicationPolicyUseCase =
      CommunicationPolicyUseCase(CommunicationPolicyRepository());

  var isLoading = false.obs;

  /// Which single OTP method should be shown/selected on the screen.
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
      final policy = await _communicationPolicyUseCase();

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
