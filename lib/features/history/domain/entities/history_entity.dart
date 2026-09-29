import 'package:equatable/equatable.dart';

class HistoryEntity extends Equatable {
  final String idAbsen;
  final String tipeAbsen;
  final DateTime waktuAbsen;
  final String statusKehadiran;

  const HistoryEntity({
    required this.idAbsen,
    required this.tipeAbsen,
    required this.waktuAbsen,
    required this.statusKehadiran,
  });

  @override
  List<Object> get props => [idAbsen, tipeAbsen, waktuAbsen, statusKehadiran];
}