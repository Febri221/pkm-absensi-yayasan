import 'package:sistem_absensi_sekolah/features/admin/data/models/admin_attendance_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/admin_class_attendance_entity.dart';
import '../../domain/repositories/admin_class_repository.dart';

class AdminClassRepositoryImpl implements AdminClassRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  // =========================================================================
  // 1. STREAM REAL-TIME REKAP ABSENSI PER KELAS
  // =========================================================================
  @override
  Stream<List<AdminClassAttendanceEntity>> streamStudentsByClass(String kelas) {
    return supabase
        .from('absensi')
        .stream(primaryKey: ['id_absen'])
        .asyncMap((absensiData) async {
          // A. Ambil data master siswa berdasarkan kelas yang dipilih
          final List<dynamic> siswaRes = await supabase
              .from('users')
              .select('id, nama_lengkap, nomor_induk, kelas')
              .eq('role', 'siswa')
              .eq('kelas', kelas)
              .eq('is_active', true);

          final today = DateTime.now().toIso8601String().split('T')[0];

          List<AdminClassAttendanceEntity> report = [];

          // B. Looping tiap siswa untuk digabungkan dengan status absensinya hari ini
          for (var siswa in siswaRes) {
            String siswaId = siswa['id'];

            // Filter absensi siswa ini untuk hari ini saja (Masuk & Pulang)
            var absenHariIni = absensiData.where((a) => 
              a['user_id'] == siswaId && 
              a['waktu_absen'].toString().startsWith(today)
            ).toList();

            String status = 'Belum Hadir';
            DateTime? waktuMasuk;
            DateTime? waktuPulang;

            for (var absen in absenHariIni) {
              if (absen['tipe_absen'] == 'masuk') {
                waktuMasuk = DateTime.parse(absen['waktu_absen']);
                status = absen['status_kehadiran'] ?? 'tepat_waktu';
              } else if (absen['tipe_absen'] == 'pulang') {
                waktuPulang = DateTime.parse(absen['waktu_absen']);
              }
            }

            // Bikin modelnya pake fromMap yang baru
            final attendanceModel = AdminClassAttendanceModel.fromMap(
              userMap: siswa, 
              statusKehadiran: status, 
              waktuMasuk: waktuMasuk, 
              waktuPulang: waktuPulang,
            );

            // Masukkan ke dalam list 'report' (sesuai nama variabel di atas)
            report.add(attendanceModel);
          }

          
          return report;
        });
  }

  // =========================================================================
  // 2. FUNGSI INPUT/KOREKSI MANUAL OLEH ADMIN (ANTI-HARDCODE)
  // =========================================================================
  @override
  Future<void> updateManualAttendance({
    required String userId, 
    required String status,
  }) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      // A. Tarik koordinat pusat sekolah secara dinamis dari tabel school_settings
      final settings = await supabase
          .from('school_settings')
          .select('school_lat, school_long')
          .single();
      
      final double schoolLat = settings['school_lat'];
      final double schoolLong = settings['school_long'];

      // B. Cek apakah siswa ini sudah punya record absensi hari ini
      final existing = await supabase
          .from('absensi')
          .select('id_absen')
          .eq('user_id', userId)
          .gte('waktu_absen', '${today}T00:00:00')
          .lte('waktu_absen', '${today}T23:59:59')
          .maybeSingle();

      if (existing != null) {
        // Kalau sudah ada, update status kehadirannya saja
        await supabase.from('absensi').update({
          'status_kehadiran': status,
        }).eq('id_absen', existing['id_absen']);
      } else {
        // Kalau belum ada (misal siswa izin/sakit/hadir manual), insert baru
        await supabase.from('absensi').insert({
          'user_id': userId,
          'tipe_absen': 'masuk',
          'latitude': schoolLat,   // <-- Dinamis dari database school_settings
          'longitude': schoolLong, // <-- Dinamis dari database school_settings
          'status_kehadiran': status,
        });
      }
    } catch (e) {
      throw Exception('Gagal melakukan input manual: $e');
    }
  }
}