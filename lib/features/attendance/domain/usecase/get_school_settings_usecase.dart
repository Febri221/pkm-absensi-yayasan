import '../repositories/attendance_repository.dart';

class GetSchoolSettingsUseCase {
  final AttendanceRepository repository;

  GetSchoolSettingsUseCase(this.repository);

  Future<Map<String, dynamic>> call() async {
    return await repository.getSchoolSettings();
  }
}