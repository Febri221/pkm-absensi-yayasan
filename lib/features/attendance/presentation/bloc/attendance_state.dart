import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_entity.dart';

sealed class AttendanceState extends Equatable {
  const AttendanceState();
  
  @override
  List<Object> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}


class AttendanceLoaded extends AttendanceState {
  final AttendanceEntity geoData;        
  final bool sudahMasuk;                 
  final bool sudahPulang;                
  final String jamPulang;                

  const AttendanceLoaded({
    required this.geoData,
    required this.sudahMasuk,
    required this.sudahPulang,
    required this.jamPulang,
  });

  @override
  List<Object> get props => [geoData, sudahMasuk, sudahPulang, jamPulang];
}

class AttendanceSubmitting extends AttendanceState {}

class AttendanceSubmitSuccess extends AttendanceState {
  final String message;

  const AttendanceSubmitSuccess(this.message);

   @override
  List<Object> get props => [message];
}

class AttendanceError extends AttendanceState {
  final String message;
  
  const AttendanceError(this.message);

  @override
  List<Object> get props => [message];
}

