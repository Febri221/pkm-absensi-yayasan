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

      // 1. Tembak login ke Supabase Auth
      final response = await supabase.auth.signInWithPassword(
        email: emailInternal,
        password: password,
      );

      final user = response.user;
      if (user == null) throw Exception('Login gagal.');

      // 2. KUNCI PENGAMAN: Cek apakah data user ini ADA di tabel users dan AKTIF?
      final cekUser = await supabase
          .from('users')
          .select('is_active')
          .eq('id', user.id)
          .maybeSingle(); // Pakai maybeSingle biar ga crash kalau datanya 0

      // Kalau datanya kosong (udah dihapus) ATAU is_active nya false
      if (cekUser == null || cekUser['is_active'] == false) {
        // Langsung cabut gelangnya (logout paksa)
        await supabase.auth.signOut();
        throw Exception('Akun Anda tidak ditemukan atau sudah dinonaktifkan.');
      }

    } catch (e) {
      // Pastikan pesan error yang dilempar bersih
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) throw Exception("Sesi login habis, silakan login ulang.");

      final emailInternal = user.email;

      if (emailInternal == null) throw Exception("Data email tidak valid.");

      await supabase.auth.signInWithPassword(
        email: emailInternal,
        password: oldPassword,
      );

      await supabase.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw Exception('Gagal mengubah password. Pastikan kata sandi lama benar');
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
