import 'package:pakland/features/auth/data/models/login_model.dart';

abstract class ILoginRepository {
  Future<Map<String, dynamic>> login(LoginRequestModel model);

  Future<Map<String, dynamic>> logoutApi(String userId);
}
