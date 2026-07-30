/// Domain-layer contract for the "forgot password" flow (password reset
/// via OTP + sending an OTP to the auth device).
/// The concrete HTTP implementation lives in
/// `data/repositories/forgot_password_repo.dart` and implements this interface.
abstract class IForgotPasswordRepository {
  Future<Map<String, dynamic>> updatePassword(Map<String, dynamic> body);

  Future<Map<String, dynamic>> sendOtpToAuthDev(Map<String, dynamic> body);
}
