import '../repositories/attendance_repository.dart';

class SubmitAttendanceUsecase {
  final AttendanceRepository repository;

  SubmitAttendanceUsecase(this.repository);

  Future<void> call({
    required double latitude,
    required double longitude,
    required String statusKehadiran,
    required String tipeAbsen,
  }) async {
    return await repository.submitAttendance(
      latitude: latitude,
      longitude: longitude,
      statusKehadiran: statusKehadiran,
      tipeAbsen: tipeAbsen,
    );
  }
}
