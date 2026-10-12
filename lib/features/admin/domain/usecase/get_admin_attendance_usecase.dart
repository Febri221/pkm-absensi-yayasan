import '../entities/admin_class_attendance_entity.dart';
import '../repositories/admin_class_repository.dart';

class GetAdminAttendanceUsecase {
  final AdminClassRepository repository;

  GetAdminAttendanceUsecase(this.repository);

   Future<List<AdminClassAttendanceEntity>> call() {
    return repository.getAdminAttendanceList();
   }
}