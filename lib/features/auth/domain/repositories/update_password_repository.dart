/// Domain-layer contract for updating the password of an already
/// authenticated user (change-password screen).
/// The concrete HTTP implementation lives in
/// `data/repositories/update_password_repo.dart` and implements this interface.
abstract class IUpdatePasswordRepository {
  Future<bool> updatePassword(Map<String, dynamic> body);
}
