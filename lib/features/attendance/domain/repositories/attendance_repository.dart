import '../entities/attendance_entity.dart';

abstract class AttendanceRepository {
    
    Future<AttendanceEntity> checkGeofence({
        required double targetLatitude,
        required double targetLongitude,
        required double radius,
    });

    Future<Map<String, dynamic>> getAttendanceStatus();

    Future<void> submitAttendance({
      required double latitude,
      required double longitude,
      required String statusKehadiran,
      required String tipeAbsen,
    });
}