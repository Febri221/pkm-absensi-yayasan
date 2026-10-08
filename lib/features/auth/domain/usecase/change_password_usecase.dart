import '../repositories/auth_repository.dart';

class ChangePasswordUsecase {
  final AuthRepository repository;
  
  ChangePasswordUsecase(this.repository);

  Future<void> call({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      throw Exception("Semua kolom wajib diisi!");
    }

    if (newPassword != confirmPassword) {
      throw Exception("Konfirmasi password baru tidak cocok!");
    }

    if (newPassword.length < 6) {
      throw Exception("Password baru minimal harus 6 karakter!");
    }

    return await repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}
