import 'package:equatable/equatable.dart';

sealed class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object> get props => [];
}

class LoadAttendanceStatusEvent extends AttendanceEvent {}

class SubmitAttendanceButtonPressed extends AttendanceEvent {
  final String tipeAbsen;

  const SubmitAttendanceButtonPressed ({

    required this.tipeAbsen,
  });

  @override
  List<Object> get props => [ tipeAbsen]; 
}