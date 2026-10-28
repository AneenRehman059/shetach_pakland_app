import 'package:pakland/features/auth/domain/repositories/update_password_repository.dart';

class UpdatePasswordUseCase {
  final IUpdatePasswordRepository _repository;

  UpdatePasswordUseCase(this._repository);

  Future<bool> call(Map<String, dynamic> body) {
    return _repository.updatePassword(body);
  }
}
