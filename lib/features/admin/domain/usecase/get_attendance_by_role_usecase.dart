import '../entities/admin_class_attendance_entity.dart';
import '../repositories/admin_class_repository.dart';

class GetAttendanceByRoleUsecase {
  final AdminClassRepository repository;

  GetAttendanceByRoleUsecase(this.repository);

  Future<List<AdminClassAttendanceEntity>> call(String role) async {
    return await repository.getAttendanceByRole(role);
  }
}