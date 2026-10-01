import 'package:equatable/equatable.dart';

class AdminAttendanceEntity extends Equatable {
  final String idAbsen;
  final String namaLengkap;
  final String nomorInduk;
  final String unitSekolah;
  final String? kelas;
  final String tipeAbsen;
  final DateTime waktuAbsen;
  final String statusKehadiran;

  const AdminAttendanceEntity({
    required this.idAbsen,
    required this.namaLengkap,
    required this.nomorInduk,
    required this.unitSekolah,
    this.kelas,
    required this.tipeAbsen,
    required this.waktuAbsen,
    required this.statusKehadiran,
  });

  @override
  List<Object?> get props => [
        idAbsen,
        namaLengkap,
        nomorInduk,
        unitSekolah,
        kelas,
        tipeAbsen,
        waktuAbsen,
        statusKehadiran,
      ];
}