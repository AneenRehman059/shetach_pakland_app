import 'package:pakland/features/auth/data/models/signup_model.dart';

abstract class IVerifyOtpRepository {
  Future<Map<String, dynamic>> verifyOtp(SignUpRequestModel model);
}
