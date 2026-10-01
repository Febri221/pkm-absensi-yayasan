import '../repositories/attendance_repository.dart';

class GetAttendanceStatusUseCase {
  final AttendanceRepository repository;

  GetAttendanceStatusUseCase(this.repository);

  // UseCase ini manggil fungsi getAttendanceStatus dari repository
  Future<Map<String, dynamic>> call() async {
    return await repository.getAttendanceStatus();
  }
}