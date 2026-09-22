import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

class CheckGeofenceUseCase {
  final AttendanceRepository repository;

  CheckGeofenceUseCase(this.repository);

  Future<AttendanceEntity> call({
    required double targetLatitude,
    required double targetLongitude,
    required double radius,
  }) async {
    return await repository.checkGeofence(
      targetLatitude: targetLatitude,
      targetLongitude: targetLongitude,
      radius: radius,
    );
  }
}
