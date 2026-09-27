abstract class AuthRepository {
  Future<void> login({required String nomorInduk, required String password});

  Future<void> changePassword({required String newPassword});

  Future<String?> getCurrentUserId();

  Future<void> logout();
}
