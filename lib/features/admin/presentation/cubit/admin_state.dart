import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_attendance_entity.dart';

sealed class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object> get props => [];
}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  final List<AdminAttendanceEntity> attendanceList;

  const AdminDashboardLoaded(this.attendanceList);

  @override
  List<Object> get props => [attendanceList];
}

class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError(this.message);

  @override
  List<Object> get props => [message];
}