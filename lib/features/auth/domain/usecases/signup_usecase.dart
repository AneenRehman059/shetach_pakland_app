import 'package:pakland/features/auth/data/models/signup_model.dart';
import 'package:pakland/features/auth/domain/repositories/signup_repository.dart';

class SignUpUseCase {
  final ISignUpRepository _repository;

  SignUpUseCase(this._repository);

  Future<Map<String, dynamic>> call(SignUpRequestModel model) {
    return _repository.signUp(model);
  }
}
