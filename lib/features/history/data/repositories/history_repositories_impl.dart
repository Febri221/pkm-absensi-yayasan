import '../../domain/entities/history_entity.dart';
import '../../domain/repositories/history_repository.dart';
import '../models/history_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryRepositoriesImpl implements HistoryRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<List<HistoryEntity>> getAttendanceHistory() async {
    try {
      final user = supabase.auth.currentUser;
      
      // DEBUG 1: Cek apakah user kedeteksi sedang login
      print("DEBUG AUTH: Current User ID = ${user?.id}");
      
      if (user == null) throw Exception('User tidak ditemukan.');

      final response = await supabase
          .from('absensi')
          .select()
          .eq('user_id', user.id)
          .order('waktu_absen', ascending: false);

      // DEBUG 2: Cek apa isi respons mentah dari Supabase
      print("DEBUG SUPABASE RESPONSE: $response");

      List<HistoryEntity> historyList = (response as List).map((data) {
        return HistoryEntity(
          idAbsen: data['id_absen'],
          tipeAbsen: data['tipe_absen'],
          waktuAbsen: DateTime.parse(data['waktu_absen']),
          statusKehadiran: data['status_kehadiran'],
        );
      }).toList();

      return historyList;
    } catch (e) {
      // DEBUG 3: Kalau ada error ketangkap di sini
      print("DEBUG ERROR HISTORY: $e");
      throw Exception('Gagal memuat riwayat: $e');
    }
  }
}
