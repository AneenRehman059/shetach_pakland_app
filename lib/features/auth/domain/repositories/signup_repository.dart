import 'package:pakland/features/auth/data/models/signup_model.dart';

/// Domain-layer contract for sign-up operations.
/// The concrete HTTP implementation lives in
/// `data/repositories/signup_repo.dart` and implements this interface.
abstract class ISignUpRepository {
  Future<Map<String, dynamic>> signUp(SignUpRequestModel model);
}
