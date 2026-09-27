import 'package:equatable/equatable.dart';

sealed class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object> get props => [];
}

class CheckLocationButtonPressed extends AttendanceEvent {}

class SubmitAttendanceButtonPressed extends AttendanceEvent {
  final double latitude;
  final double longitude;
  final String tipeAbsen;

  const SubmitAttendanceButtonPressed ({
    required this.latitude,
    required this.longitude,
    required this.tipeAbsen,
  });

  @override
  List<Object> get props => [latitude, longitude, tipeAbsen]; 
}