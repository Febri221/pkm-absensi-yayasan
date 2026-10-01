import 'package:geolocator/geolocator.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AttendanceRepositoryImpl implements AttendanceRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<AttendanceEntity> checkGeofence({
    required double targetLatitude,
    required double targetLongitude,
    required double radius,
  }) async {
    // 1. CEK APAKAH GPS/LOCATION SERVICE NYALA ATAU MATI DULU!
    // Ini harus dicek paling awal sebelum ngurusin permission.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Di sini kita lempar pesan yang jelas ke BLoC/UI
      // supaya UI bisa nangkep dan nampilin pop-up atau dialog peringatan nyalain GPS.
      throw Exception('GPS_DISABLED');
    }

    // 2. BARU CEK PERMISSION (IZIN APLIKASI)
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin akses lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi diblokir permanen dari pengaturan HP. Harap izinkan secara manual.',
      );
    }

    // 3. KALAU SEMUA AMAN, TARIK POSISI REAL-TIME
    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 4. HITUNG JARAK (RUMUS HAVERSINE)
    double distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      targetLatitude,
      targetLongitude,
    );

    bool isInside = distance <= radius;

    return AttendanceEntity(
      distanceInMeters: distance,
      isWithinRadius: isInside,
    );
  }

  @override
  Future<Map<String, dynamic>> getAttendanceStatus() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Sesi login habis.');

    final today = DateTime.now().toIso8601String().split('T')[0];

    // 1. Cek riwayat absen hari ini
    final response = await supabase
        .from('absensi')
        .select()
        .eq('user_id', user.id)
        .gte('waktu_absen', '${today}T00:00:00')
        .lte('waktu_absen', '${today}T23:59:59');

    bool sudahMasuk = false;
    bool sudahPulang = false;

    for (var item in response) {
      if (item['tipe_absen'] == 'masuk') sudahMasuk = true;
      if (item['tipe_absen'] == 'pulang') sudahPulang = true;
    }

    // 2. Ambil profil user (buat tau dia 'smp' atau 'smk')
    final userData = await supabase
        .from('users')
        .select('tingkat')
        .eq('id', user.id)
        .single();
    
    final String tingkat = userData['tingkat'] ?? 'smp';

    // 3. AMBIL KONFIGURASI DARI DATABASE SUPABASE (TIDAK ADA HARDCODE!)
    final settings = await supabase.from('school_settings').select().single();
    
    // Ambil jam pulang murni dari database berdasarkan tingkat siswa
    final String jamPulangStr = (tingkat == 'smp') 
        ? settings['jam_pulang_smp'] 
        : settings['jam_pulang_smk'];

    return {
      'sudahMasuk': sudahMasuk,
      'sudahPulang': sudahPulang,
      'tingkat': tingkat,
      'jamPulang': jamPulangStr, // Format "14:10:00" dari database
    };
  }

  @override
  Future<void> submitAttendance({
    required double latitude,
    required double longitude,
    required String statusKehadiran,
    required String tipeAbsen,
  }) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Sesi login habis, silakan login ulang');
      }

      print("DEBUG: User ID yang sedang aktif adalah: ${user.id}");

      final userData = await supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .single();

      final String roleUser = userData['role'];

      String statusFinal = statusKehadiran;

      if (roleUser == 'siswa') {
        if (tipeAbsen == 'masuk') {
          final settings = await supabase
              .from('school_settings')
              .select()
              .single();
          final String jamMasukStr = settings['jam_masuk'] ?? '06:30:00';
          final int toleransiMenit = settings['toleransi_telat_menit'] ?? 15;

          final now = DateTime.now();
          final parts = jamMasukStr.split(':');
          final jamMasukSekolah = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
          final batasTelat = jamMasukSekolah.add(
            Duration(minutes: toleransiMenit),
          );

          if (now.isAfter(batasTelat)) {
            statusFinal = 'terlambat';
          } else {
            statusFinal = 'tepat_waktu';
          }
        } else {
          statusFinal = 'hadir_pulang';
        }
      } else {
        statusFinal = 'tepat_waktu';
      }

      await supabase.from('absensi').insert({
        'user_id': user.id,
        'tipe_absen': tipeAbsen,
        'latitude': latitude,
        'longitude': longitude,
        'status_kehadiran': statusFinal,
      });
    } catch (e) {
      throw Exception('Gagal mengirim absen: $e');
    }
  }
}
