import 'package:pakland/features/auth/domain/repositories/login_repository.dart';

class LogoutUseCase {
  final ILoginRepository _repository;

  LogoutUseCase(this._repository);

  Future<Map<String, dynamic>> call(String userId) {
    return _repository.logoutApi(userId);
  }
}
