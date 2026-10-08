import 'package:equatable/equatable.dart';

class AdminClassAttendanceEntity extends Equatable {
  final String idSiswa;
  final String namaLengkap;
  final String nomorInduk;
  final String kelas;
  final String? tipeAbsen;
  final DateTime? waktuMasuk;
  final DateTime? waktuPulang;
  final String statusKehadiran;
  final bool isSelected;

  const AdminClassAttendanceEntity({
    required this.idSiswa,
    required this.namaLengkap,
    required this.nomorInduk,
    required this.kelas,
    required this.statusKehadiran,
    this.tipeAbsen,
    this.waktuMasuk,
    this.waktuPulang,
    this.isSelected = false,
  });

  AdminClassAttendanceEntity copyWith({bool? isSelected}) {
    return AdminClassAttendanceEntity(
      idSiswa: idSiswa,
      namaLengkap: namaLengkap,
      nomorInduk: nomorInduk,
      kelas: kelas,
      statusKehadiran: statusKehadiran,
      tipeAbsen: tipeAbsen,
      waktuMasuk: waktuMasuk,
      waktuPulang: waktuPulang,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [
    idSiswa,
    namaLengkap,
    nomorInduk,
    kelas,
    tipeAbsen,
    waktuMasuk,
    waktuPulang,
    statusKehadiran,
    isSelected,
  ];
}

