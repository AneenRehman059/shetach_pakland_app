import 'package:pakland/features/auth/data/models/login_model.dart';
import 'package:pakland/features/auth/domain/repositories/login_repository.dart';

class LoginUseCase {
  final ILoginRepository _repository;

  LoginUseCase(this._repository);

  Future<Map<String, dynamic>> call(LoginRequestModel model) {
    return _repository.login(model);
  }
}
