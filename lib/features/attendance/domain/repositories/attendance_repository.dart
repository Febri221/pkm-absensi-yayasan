import '../entities/attendance_entity.dart';

abstract class AttendanceRepository {
    
    Future<AttendanceEntity> checkGeofence({
        required double targetLatitude,
        required double targetLongitude,
        required double radius,
    });
}