import 'package:pakland/features/auth/data/models/signup_model.dart';

abstract class ISignUpRepository {
  Future<Map<String, dynamic>> signUp(SignUpRequestModel model);
}
