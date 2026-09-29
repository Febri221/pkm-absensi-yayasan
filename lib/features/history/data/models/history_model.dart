import '../../domain/entities/history_entity.dart';

class HistoryModel extends HistoryEntity {
  const HistoryModel({
    required super.idAbsen,
    required super.tipeAbsen,
    required super.waktuAbsen,
    required super.statusKehadiran,
  });

  // Alat penerjemah dari JSON Supabase ke Model/Entity
  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      idAbsen: json['id_absen'],
      tipeAbsen: json['tipe_absen'],
      waktuAbsen: DateTime.parse(json['waktu_absen']),
      statusKehadiran: json['status_kehadiran'],
    );
  }
}