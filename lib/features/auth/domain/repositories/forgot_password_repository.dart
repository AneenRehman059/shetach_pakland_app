abstract class IForgotPasswordRepository {
  Future<Map<String, dynamic>> updatePassword(Map<String, dynamic> body);

  Future<Map<String, dynamic>> sendOtpToAuthDev(Map<String, dynamic> body);
}
