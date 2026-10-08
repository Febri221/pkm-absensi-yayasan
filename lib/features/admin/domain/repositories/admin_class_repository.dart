import '../entities/admin_class_attendance_entity.dart';

abstract class AdminClassRepository {
 Stream<List<AdminClassAttendanceEntity>> streamStudentsByClass(String kelas);

 Future<void>updateManualAttendance({
    required String userId, 
    required String status,
  });
}

