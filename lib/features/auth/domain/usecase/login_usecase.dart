import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<void> call({
    required String nomorInduk,
    required String password,
  }) async {
    if (nomorInduk.isEmpty || password.isEmpty) {
      throw Exception('Nomor Induk dan Password tidak boleh kosong!');
    }

    return await repository.login(nomorInduk: nomorInduk, password: password);
  }
}
