import 'package:pakland/features/auth/domain/repositories/update_password_repository.dart';

/// Business action: change the password of the currently logged-in user.
class UpdatePasswordUseCase {
  final IUpdatePasswordRepository _repository;

  UpdatePasswordUseCase(this._repository);

  Future<bool> call(Map<String, dynamic> body) {
    return _repository.updatePassword(body);
  }
}
