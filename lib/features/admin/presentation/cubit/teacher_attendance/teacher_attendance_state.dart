import 'package:equatable/equatable.dart';
import '../../../domain/entities/admin_class_attendance_entity.dart';

sealed class TeacherAttendanceState extends Equatable {
  const TeacherAttendanceState();
  
  @override
  List<Object> get props => [];
}

class TeacherAttendanceInitial extends TeacherAttendanceState {}

class TeacherAttendanceLoading extends TeacherAttendanceState {}

class TeacherAttendanceLoaded extends TeacherAttendanceState {
  final List<AdminClassAttendanceEntity> teachers;
  const TeacherAttendanceLoaded(this.teachers);

  @override
  List<Object> get props => [teachers];
}

class TeacherAttendanceError extends TeacherAttendanceState {
  final String message;
  const TeacherAttendanceError(this.message);

  @override
  List<Object> get props => [message];
}