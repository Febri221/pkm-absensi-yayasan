import '../entities/admin_attendance_entity.dart';

abstract class AdminAttendanceRepository {
  Future<List<AdminAttendanceEntity>> getAdminAttendanceList();
}