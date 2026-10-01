import '../../domain/entities/admin_attendance_entity.dart';

class AdminAttendanceModel extends AdminAttendanceEntity {
  const AdminAttendanceModel({
    required super.idAbsen,
    required super.namaLengkap,
    required super.nomorInduk,
    required super.unitSekolah,
    super.kelas,
    required super.tipeAbsen,
    required super.waktuAbsen,
    required super.statusKehadiran,
  });

  factory AdminAttendanceModel.fromJson(Map<String, dynamic> json) {
    // Ambil data relasi dari tabel users (Supabase nge-join pake nama key 'users')
    final user = json['users'] ?? {};

    return AdminAttendanceModel(
      idAbsen: json['id_absen'] ?? '',
      namaLengkap: user['nama_lengkap'] ?? 'Tanpa Nama',
      nomorInduk: user['nomor_induk'] ?? '-',
      unitSekolah: user['unit_sekolah'] ?? '-',
      kelas: user['kelas'],
      tipeAbsen: json['tipe_absen'] ?? '-',
      // Pastikan format parsing tanggal ini aman
      waktuAbsen: json['waktu_absen'] != null 
          ? DateTime.parse(json['waktu_absen']) 
          : DateTime.now(),
      statusKehadiran: json['status_kehadiran'] ?? '-',
    );
  }
}