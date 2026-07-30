import 'package:pakland/features/auth/data/models/signup_model.dart';

/// Domain-layer contract for OTP verification.
/// The concrete HTTP implementation lives in
/// `data/repositories/verify_otp_repo.dart` and implements this interface.
abstract class IVerifyOtpRepository {
  Future<Map<String, dynamic>> verifyOtp(SignUpRequestModel model);
}
