import '../repositories/attendance_repository.dart';

class SubmitAttendanceUseCase {
  final AttendanceRepository repository;

  SubmitAttendanceUseCase(this.repository);

  Future<void> call({
    
    required String tipeAbsen,
  }) async {
    return await repository.submitAttendance(
      
      tipeAbsen: tipeAbsen,
    );
  }
}
