import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/admin_attendance_repository.dart';
import '../models/admin_attendance_model.dart';

class AdminAttendanceRepositoryImpl implements AdminAttendanceRepository {
  final SupabaseClient supabase = Supabase.instance.client;

 @override
Future<List<AdminAttendanceModel>> getAdminAttendanceList() async {
  try {
    // Tarik langsung murni dari tabel absensi dan join ke users
    final response = await supabase
        .from('absensi')
        .select('id_absen, tipe_absen, waktu_absen, status_kehadiran, users(nama_lengkap, nomor_induk, unit_sekolah, kelas)')
        .order('waktu_absen', ascending: false)
        .limit(50); // Tarik 50 data terbaru secara global

        print("ISI MENTAH SUPABASE: $response");

    final List<AdminAttendanceModel> result = (response as List).map((data) {
      return AdminAttendanceModel.fromJson(data);
    }).toList();

    return result;
  } catch (e) {
    throw Exception('Gagal menarik data rekap admin: $e');
  }
}
}