import 'package:sistem_absensi_sekolah/features/admin/data/models/admin_attendance_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/admin_class_attendance_entity.dart';
import '../../domain/repositories/admin_class_repository.dart';
import 'package:csv/csv.dart';

class AdminAttendanceRepositoryImpl implements AdminClassRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<List<AdminClassAttendanceEntity>> getAdminAttendanceList() async {
    // Kueri rekap global harian
    try {
      final response = await supabase
          .from('absensi')
          .select(
            'id_absen, tipe_absen, waktu_absen, status_kehadiran, users(nama_lengkap, nomor_induk, unit_sekolah, kelas)',
          )
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
          waktuMasuk: data['tipe_absen'] == 'masuk'
              ? DateTime.parse(data['waktu_absen'])
              : null,
          waktuPulang: data['tipe_absen'] == 'pulang'
              ? DateTime.parse(data['waktu_absen'])
              : null,
          statusKehadiran: data['status_kehadiran'] ?? '-',
        );
      }).toList();
    } catch (e) {
      throw Exception('Gagal menarik rekap admin: $e');
    }
  }

  @override
  Stream<List<AdminClassAttendanceEntity>> streamStudentsByClass(String kelas) {
    return supabase.from('absensi').stream(primaryKey: ['id_absen']).asyncMap((
      _,
    ) async {
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
        var absenHariIni = absensiRes
            .where(
              (a) =>
                  a['user_id'] == siswaId &&
                  a['waktu_absen'].toString().startsWith(today),
            )
            .toList();

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

      final settings = await supabase
          .from('school_settings')
          .select('school_lat, school_long')
          .single();

      final double schoolLat = settings['school_lat'];
      final double schoolLong = settings['school_long'];

      // AMAN: Pakai .limit(1) 
      final existingList = await supabase
          .from('absensi')
          .select('id_absen')
          .eq('user_id', userId)
          .gte('waktu_absen', '${today}T00:00:00')
          .lte('waktu_absen', '${today}T23:59:59')
          .limit(1);

      if (existingList.isNotEmpty) {
        final existingId = existingList.first['id_absen'];
        await supabase
            .from('absensi')
            .update({'status_kehadiran': status})
            .eq('id_absen', existingId);
      } else {
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
      List<List<dynamic>> rowsAsListOfValues = csv.decode(csvStringContent);

      if (rowsAsListOfValues.isEmpty) {
        throw Exception('File CSV kosong atau format tidak valid.');
      }

      for (int i = 1; i < rowsAsListOfValues.length; i++) {
        var row = rowsAsListOfValues[i];

        // Skip jika baris benar-benar kosong melompong
        if (row.isEmpty || row[0] == null || row[0].toString().trim().isEmpty)
          continue;

        // Ambil data dengan aman menggunakan pengecekan index
        String nomorInduk = row.length > 0 && row[0] != null
            ? row[0].toString().trim()
            : '';
        String namaLengkap = row.length > 1 && row[1] != null
            ? row[1].toString().trim()
            : 'Tanpa Nama';
        String role = row.length > 2 && row[2] != null
            ? row[2].toString().trim().toLowerCase()
            : 'siswa';
        String unitSekolah = row.length > 3 && row[3] != null
            ? row[3].toString().trim()
            : 'Pusat';

        String? tingkat =
            (row.length > 4 &&
                row[4] != null &&
                row[4].toString().trim().isNotEmpty)
            ? row[4].toString().trim().toLowerCase()
            : null;

        String? kelas =
            (row.length > 5 &&
                row[5] != null &&
                row[5].toString().trim().isNotEmpty)
            ? row[5].toString().trim()
            : null;

        final emailInternal = "$nomorInduk@absensi.sekolah.internal";
        String passwordDefault = "sekolah123";

        try {
          String? userId;

          // 1. Daftarkan dulu ke Supabase Auth untuk mendapatkan UUID (id)
          final authResponse = await supabase.auth.signUp(
            email: emailInternal,
            password: passwordDefault,
          );
          userId = authResponse.user?.id;

          // 2. Jika karena suatu hal userId null (misal email sudah ada),
          // kita ambil ID-nya berdasarkan email atau nomor_induk
          if (userId == null) {
            // Opsional: cari user yang sudah ada
            final existingUser = await supabase
                .from('users')
                .select('id')
                .eq('nomor_induk', nomorInduk)
                .maybeSingle();
            if (existingUser != null) {
              userId = existingUser['id'];
            }
          }

          if (userId != null) {
            // 3. Masukkan dengan menyertakan 'id' yang valid!
            await supabase.from('users').upsert(
              {
                'id': userId, // <-- INI YANG KETINGGALAN DAN BIKIN ERROR NULL!
                'nomor_induk': nomorInduk,
                'nama_lengkap': namaLengkap,
                'role': role,
                'unit_sekolah': unitSekolah,
                'tingkat': (role == 'siswa') ? tingkat : null,
                'kelas': (role == 'siswa') ? kelas : null,
                'tahun_ajaran': '2025/2026',
                'is_active': true,
              },
              onConflict: 'id',
            ); // Konflik di-handle berdasarkan id atau nomor_induk
          }

          print("Berhasil insert/update user: $namaLengkap ($role)");
        } catch (rowError) {
          print("Gagal memproses baris $nomorInduk ($namaLengkap): $rowError");
        }
      }
    } catch (e) {
      throw Exception('Gagal memproses file CSV: $e');
    }
  }

  @override
  Future<List<AdminClassAttendanceEntity>> getAttendanceByRole(
    String role,
  ) async {
    try {
      final List<dynamic> staffRes = await supabase
          .from('users')
          .select('id, nama_lengkap, nomor_induk, unit_sekolah')
          .eq(
            'role',
            role,
          ) // Nyaring murni berdasarkan role ('guru' atau 'karyawan')
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
        var absenHariIni = absensiRes
            .where((a) => a['user_id'] == staffId)
            .toList();

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

        finalReport.add(
          AdminClassAttendanceEntity(
            idSiswa:
                staffId, // (Variabel entity bisa dipake bersama buat guru/karyawan)
            namaLengkap: staff['nama_lengkap'] ?? 'Tanpa Nama',
            nomorInduk: staff['nomor_induk'] ?? '-',
            unitSekolah: staff['unit_sekolah'] ?? '-',
            kelas: '-',
            waktuMasuk: waktuMasuk,
            waktuPulang: waktuPulang,
            statusKehadiran: status,
          ),
        );
      }

      return finalReport;
    } catch (e) {
      throw Exception('Gagal menarik data rekap $role: $e');
    }
  }

  @override
  Future<Map<String, List<String>>> getAvailableClasses() async {
    // 1. Tarik semua data siswa yang aktif dan punya kelas
    final response = await supabase
        .from('users')
        .select('unit_sekolah, kelas')
        .eq('role', 'siswa')
        .eq('is_active', true);

    // 2. Olah data jadi Map dinamis { 'SMP 136': ['IX A', 'IX B'], 'SMK 155': [...] }
    Map<String, List<String>> result = {};

    for (var row in response) {
      String unit = row['unit_sekolah'] ?? 'Lainnya';
      String kelas = row['kelas'] ?? '-';
      if (kelas == '-') continue;

      if (!result.containsKey(unit)) {
        result[unit] = [];
      }

      if (!result[unit]!.contains(kelas)) {
        result[unit]!.add(kelas);
      }
    }

    // Sort tiap list kelas biar rapi (A, B, C...)
    result.forEach((key, value) => value.sort());

    return result;
  }

  @override
  Future<void> bulkUpdateAttendance({
    required List<String> userIds,
    required String status,
  }) async {
    try {
      if (userIds.isEmpty) return;

      final today = DateTime.now().toIso8601String().split('T')[0];

      final settings = await supabase
          .from('school_settings')
          .select('school_lat, school_long')
          .single();

      final double schoolLat = settings['school_lat'];
      final double schoolLong = settings['school_long'];

      for (String userId in userIds) {
        // AMAN: Pakai .limit(1) alih-alih .maybeSingle() agar tidak kena error 406 jika ada data dobel
        final existingList = await supabase
            .from('absensi')
            .select('id_absen')
            .eq('user_id', userId)
            .gte('waktu_absen', '${today}T00:00:00')
            .lte('waktu_absen', '${today}T23:59:59')
            .limit(1);

        if (existingList.isNotEmpty) {
          final existingId = existingList.first['id_absen'];
          await supabase
              .from('absensi')
              .update({'status_kehadiran': status})
              .eq('id_absen', existingId);
        } else {
          await supabase.from('absensi').insert({
            'user_id': userId,
            'tipe_absen': 'masuk',
            'latitude': schoolLat,
            'longitude': schoolLong,
            'status_kehadiran': status,
          });
        }
      }
    } catch (e) {
      throw Exception('Gagal melakukan update masal: $e');
    }
  }
}
