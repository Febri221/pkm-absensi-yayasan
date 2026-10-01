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

      if (user == null) throw Exception('User tidak ditemukan.');

      final response = await supabase
          .from('absensi')
          .select()
          .eq('user_id', user.id)
          .order('waktu_absen', ascending: false);

      List<HistoryModel> historyList = (response as List).map((data) {
        return HistoryModel.fromJson(data);
      }).toList();

      return historyList;
    } catch (e) {
        throw Exception('Gagal memuat riwayat: $e');
    }
  }
}
