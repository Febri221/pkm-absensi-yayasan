import 'package:equatable/equatable.dart';
import '../../../domain/entities/admin_class_attendance_entity.dart';

sealed class EmployeeAttendanceState extends Equatable {
  const EmployeeAttendanceState();

  @override
  List<Object> get props => [];
}

class EmployeeAttendanceInitial extends EmployeeAttendanceState {}

class EmployeeAttendanceLoading extends EmployeeAttendanceState {}

class EmployeeAttendanceLoaded extends EmployeeAttendanceState {
  final List<AdminClassAttendanceEntity> employees;
  const EmployeeAttendanceLoaded(this.employees);

  @override
  List<Object> get props => [employees];
}

class EmployeeAttendanceError extends EmployeeAttendanceState {
  final String message;
  const EmployeeAttendanceError(this.message);

  @override
  List<Object> get props => [message];
}