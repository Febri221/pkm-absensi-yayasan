import '../entities/admin_class_attendance_entity.dart';
import '../repositories/admin_class_repository.dart';

class GetAttendanceByClassUseCase {
  final AdminClassRepository repository;

  GetAttendanceByClassUseCase(this.repository);

  Stream<List<AdminClassAttendanceEntity>> call(String kelas) {
    return repository.streamStudentsByClass(kelas);
  }
}