import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_class_attendance_entity.dart';

sealed class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object> get props => [];
}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  final List<AdminClassAttendanceEntity> students;
  final String selectedClass;

  const AdminDashboardLoaded({required this.students, required this.selectedClass});

  @override
  List<Object> get props => [students, selectedClass];
}

class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError(this.message);

  @override
  List<Object> get props => [message];
}