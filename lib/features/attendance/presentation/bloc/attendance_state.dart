import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_entity.dart';

sealed class AttendanceState extends Equatable {
  const AttendanceState();
  
  @override
  List<Object> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

// Kalau sukses dapet lokasi, kita bawa data Entity-nya ke UI
class AttendanceLoaded extends AttendanceState {
  final AttendanceEntity data;
  const AttendanceLoaded(this.data);

  @override
  List<Object> get props => [data];
}

class AttendanceError extends AttendanceState {
  final String message;
  const AttendanceError(this.message);

  @override
  List<Object> get props => [message];
}