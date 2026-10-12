import 'package:sistem_absensi_sekolah/features/admin/data/models/admin_attendance_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/admin_class_attendance_entity.dart';
import '../../domain/repositories/admin_class_repository.dart';
import 'package:csv/csv.dart';

class AdminClassRepositoryImpl implements AdminClassRepository {
  final SupabaseClient supabase = Supabase.instance.client;

   @override
  Future<List<AdminClassAttendanceEntity>> getAdminAttendanceList() async {
    // Kueri rekap global harian
    try {
      final response = await supabase
          .from('absensi')
          .select('id_absen, tipe_absen, waktu_absen, status_kehadiran, users(nama_lengkap, nomor_induk, unit_sekolah, kelas)')
          .order('waktu_absen', ascending: false)
          .limit(50);

      return (response as List).map((data) {
        final user = data['users'] ?? {};
        return AdminClassAttendanceEntity(
          idSiswa: data['user_id'] ?? '',
          namaLengkap: user['nama_lengkap'] ?? 'Tanpa Nama',
          nomorInduk: user['nomor_induk'] ?? '-',
          unitSekolah: user['unit_sekolah'] ?? '-',
          kelas: user['kelas'],
          tipeAbsen: data['tipe_absen'],
          waktuMasuk: data['tipe_absen'] == 'masuk' ? DateTime.parse(data['waktu_absen']) : null,
          waktuPulang: data['tipe_absen'] == 'pulang' ? DateTime.parse(data['waktu_absen']) : null,
          statusKehadiran: data['status_kehadiran'] ?? '-',
        );
      }).toList();
    } catch (e) {
      throw Exception('Gagal menarik rekap admin: $e');
    }
  }


  @override
  Stream<List<AdminClassAttendanceEntity>> streamStudentsByClass(String kelas) {
    return supabase
        .from('absensi')
        .stream(primaryKey: ['id_absen'])
        .asyncMap((_) async {
          // A. Ambil data master siswa berdasarkan kelas yang dipilih
          final List<dynamic> siswaRes = await supabase
              .from('users')
              .select('id, nama_lengkap, nomor_induk, kelas')
              .eq('role', 'siswa')
              .eq('kelas', kelas)
              .eq('is_active', true);

            if (siswaRes.isEmpty) return [];

          final today = DateTime.now().toIso8601String().split('T')[0];

            final List<dynamic> absensiRes = await supabase
              .from('absensi')
              .select('*')
              .gte('waktu_absen', '${today}T00:00:00')
              .lte('waktu_absen', '${today}T23:59:59');


          List<AdminClassAttendanceEntity> report = [];

          // B. Looping tiap siswa untuk digabungkan dengan status absensinya hari ini
          for (var siswa in siswaRes) {
            String siswaId = siswa['id'];

            // Filter absensi siswa ini untuk hari ini saja (Masuk & Pulang)
            var absenHariIni = absensiRes.where((a) => 
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
          'latitude': schoolLat, 
          'longitude': schoolLong, 
          'status_kehadiran': status,
        });
      }
    } catch (e) {
      throw Exception('Gagal melakukan input manual: $e');
    }
  }


   @override
  Future<void> bulkInsertUsersFromCsv(String csvStringContent) async {
    try {
      // 1. Konversi string teks CSV mentah menggunakan csv.decode
      List<List<dynamic>> rowsAsListOfValues = csv.decode(csvStringContent);

      if (rowsAsListOfValues.isEmpty) {
        throw Exception('File CSV kosong atau format tidak valid.');
      }

      // 2. Looping mulai dari baris kedua (index 1) karena index 0 adalah Header
      // Format Header CSV yang benar: [nomor_induk, nama_lengkap, role, unit_sekolah, tingkat, kelas]
      for (int i = 1; i < rowsAsListOfValues.length; i++) {
        var row = rowsAsListOfValues[i];
        
        // Pastikan minimal ada 4 kolom utama (nomor_induk, nama_lengkap, role, unit_sekolah)
        if (row.length < 4) continue; 

        String nomorInduk = row[0].toString().trim();
        String namaLengkap = row[1].toString().trim();
        String role = row[2].toString().trim().toLowerCase(); // 'siswa', 'guru', atau 'karyawan'
        String unitSekolah = row[3].toString().trim();        // 'SMP 136' atau 'Pusat'
        
        // Untuk tingkat dan kelas (index 4 dan 5), cek dulu apakah ada isinya (Aman buat guru/karyawan yang kosong)
        String? tingkat = (row.length > 4 && row[4] != null && row[4].toString().trim().isNotEmpty) 
            ? row[4].toString().trim().toLowerCase() 
            : null;
            
        String? kelas = (row.length > 5 && row[5] != null && row[5].toString().trim().isNotEmpty) 
            ? row[5].toString().trim() 
            : null;

        // 3. Buat format email internal otomatis
        final emailInternal = "$nomorInduk@absensi.sekolah.internal";
        final passwordDefault = "sekolah123"; // Password default awal

        try {
          // 4. Daftarkan ke Supabase Auth
          final authResponse = await supabase.auth.signUp(
            email: emailInternal,
            password: passwordDefault,
          );

          final userId = authResponse.user?.id;

          if (userId != null) {
            // 5. Masukkan profil lengkap ke tabel 'users'
            // Guru & Karyawan otomatis kolom tingkat & kelas-nya terisi NULL dengan aman!
            await supabase.from('users').upsert({
              'id': userId,
              'nomor_induk': nomorInduk,
              'nama_lengkap': namaLengkap,
              'role': role,
              'unit_sekolah': unitSekolah,
              'tingkat': (role == 'siswa') ? tingkat : null, // Guru/karyawan dipaksa null
              'kelas': (role == 'siswa') ? kelas : null,       // Guru/karyawan dipaksa null
              'tahun_ajaran': '2025/2026',
              'is_active': true,
            });
          }
        } catch (authError) {
          print("Skipping or error for NISN/NIP $nomorInduk: $authError");
        }
      }
    } catch (e) {
      throw Exception('Gagal memproses file CSV: $e');
    }
  }

  @override
  Future<List<AdminClassAttendanceEntity>> getAttendanceByRole(String role) async {
    try {
      final List<dynamic> staffRes = await supabase
          .from('users')
          .select('id, nama_lengkap, nomor_induk, unit_sekolah')
          .eq('role', role) // Nyaring murni berdasarkan role ('guru' atau 'karyawan')
          .eq('is_active', true);

      if (staffRes.isEmpty) return [];

      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final List<dynamic> absensiRes = await supabase
          .from('absensi')
          .select('*')
          .gte('waktu_absen', '${today}T00:00:00')
          .lte('waktu_absen', '${today}T23:59:59');

      List<AdminClassAttendanceEntity> finalReport = [];

      for (var staff in staffRes) {
        String staffId = staff['id'];
        var absenHariIni = absensiRes.where((a) => a['user_id'] == staffId).toList();

        DateTime? waktuMasuk;
        DateTime? waktuPulang;
        String status = 'Belum Hadir';

        for (var absen in absenHariIni) {
          if (absen['tipe_absen'] == 'masuk') {
            waktuMasuk = DateTime.parse(absen['waktu_absen']);
            status = absen['status_kehadiran'] ?? 'tepat_waktu';
          } else if (absen['tipe_absen'] == 'pulang') {
            waktuPulang = DateTime.parse(absen['waktu_absen']);
          }
        }

        finalReport.add(AdminClassAttendanceEntity(
          idSiswa: staffId, // (Variabel entity bisa dipake bersama buat guru/karyawan)
          namaLengkap: staff['nama_lengkap'] ?? 'Tanpa Nama',
          nomorInduk: staff['nomor_induk'] ?? '-',
          unitSekolah: staff['unit_sekolah'] ?? '-',
          kelas: '-', 
          waktuMasuk: waktuMasuk,
          waktuPulang: waktuPulang,
          statusKehadiran: status,
        ));
      }

      return finalReport;
    } catch (e) {
      throw Exception('Gagal menarik data rekap $role: $e');
    }
  }
}