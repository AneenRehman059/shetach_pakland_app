import 'package:pakland/features/auth/domain/repositories/forgot_password_repository.dart';

/// Business action: send an OTP to the device associated with the
/// account (start of the "forgot password" flow).
class SendOtpAuthDeviceUseCase {
  final IForgotPasswordRepository _repository;

  SendOtpAuthDeviceUseCase(this._repository);

  Future<Map<String, dynamic>> call(Map<String, dynamic> body) {
    return _repository.sendOtpToAuthDev(body);
  }
}
