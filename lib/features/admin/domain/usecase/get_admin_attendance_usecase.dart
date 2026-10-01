import '../entities/admin_attendance_entity.dart';
import '../repositories/admin_attendance_repository.dart';

class GetAdminAttendanceUseCase {
  final AdminAttendanceRepository repository;

  GetAdminAttendanceUseCase(this.repository);

  Future<List<AdminAttendanceEntity>> call() async {
    return await repository.getAdminAttendanceList();
  }
}