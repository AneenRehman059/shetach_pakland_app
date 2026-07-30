import 'package:pakland/features/auth/data/models/login_model.dart';

/// Domain-layer contract for login/logout operations.
/// The concrete HTTP implementation lives in
/// `data/repositories/login_repo.dart` and implements this interface.
abstract class ILoginRepository {
  Future<Map<String, dynamic>> login(LoginRequestModel model);

  Future<Map<String, dynamic>> logoutApi(String userId);
}
