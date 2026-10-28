abstract class IUpdatePasswordRepository {
  Future<bool> updatePassword(Map<String, dynamic> body);
}
