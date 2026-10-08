import '../../domain/entities/admin_class_attendance_entity.dart';

class AdminClassAttendanceModel extends AdminClassAttendanceEntity {
  const AdminClassAttendanceModel({
   required super.idSiswa,
    required super.namaLengkap,
    required super.nomorInduk,
    required super.kelas,
    required super.statusKehadiran,
    super.tipeAbsen,
    super.waktuMasuk,
    super.waktuPulang,
    super.isSelected,
  });

factory AdminClassAttendanceModel.fromMap({
    required Map<String, dynamic> userMap,
    required String statusKehadiran,
    DateTime? waktuMasuk,
    DateTime? waktuPulang,
  }) {
    return AdminClassAttendanceModel(
      idSiswa: userMap['id'] ?? '',
      namaLengkap: userMap['nama_lengkap'] ?? 'Tanpa Nama',
      nomorInduk: userMap['nomor_induk'] ?? '-',
      kelas: userMap['kelas'] ?? '-',
      statusKehadiran: statusKehadiran,
      waktuMasuk: waktuMasuk,   // Masuk ke Entity
      waktuPulang: waktuPulang, // Masuk ke Entity
    );
  }
}