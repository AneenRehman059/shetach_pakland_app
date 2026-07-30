import 'package:pakland/features/auth/data/models/signup_model.dart';
import 'package:pakland/features/auth/domain/repositories/verify_otp_repository.dart';

/// Business action: verify an OTP code (signup, login-device auth, and
/// password-reset flows all share this).
class VerifyOtpUseCase {
  final IVerifyOtpRepository _repository;

  VerifyOtpUseCase(this._repository);

  Future<Map<String, dynamic>> call(SignUpRequestModel model) {
    return _repository.verifyOtp(model);
  }
}
