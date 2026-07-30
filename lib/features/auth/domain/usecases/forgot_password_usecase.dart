import 'package:pakland/features/auth/domain/repositories/forgot_password_repository.dart';

/// Business action: submit a new password as part of the "forgot
/// password" reset flow.
class ForgotPasswordUseCase {
  final IForgotPasswordRepository _repository;

  ForgotPasswordUseCase(this._repository);

  Future<Map<String, dynamic>> call(Map<String, dynamic> body) {
    return _repository.updatePassword(body);
  }
}
