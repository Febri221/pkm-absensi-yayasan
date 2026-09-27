import '../../domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<void> login({
    required String nomorInduk,
    required String password,
  }) async {
    try {
      final emailInternal = "$nomorInduk@absensi.sekolah.internal";

      await supabase.auth.signInWithPassword(
        email: emailInternal,
        password: password,
      );
    } catch (e) {
      throw Exception(
        'Gagal login: Periksa kembali Nomor Induk dan Kata Sandi Anda.',
      );
    }
  }

  @override
  Future<void> changePassword({
    required String newPassword
  }) async {

    try {
        await supabase.auth.updateUser(
            UserAttributes(password: newPassword)
        );
    } catch (e) {
        throw Exception('Gagal mengubah password: $e');
    }
  }


  @override
  Future<String?> getCurrentUserId() async {
    final user = supabase.auth.currentUser;
    return user?.id;
  }

  @override
  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
