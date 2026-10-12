import '../entities/admin_class_attendance_entity.dart';

abstract class AdminClassRepository {

  Future<List<AdminClassAttendanceEntity>> getAdminAttendanceList();
  
  Stream<List<AdminClassAttendanceEntity>> streamStudentsByClass(String kelas);

  Future<void>updateManualAttendance({
    required String userId, 
    required String status,
  });

  Future<void> bulkInsertUsersFromCsv(String csvStringContent);

  Future<List<AdminClassAttendanceEntity>> getAttendanceByRole(String role);
}