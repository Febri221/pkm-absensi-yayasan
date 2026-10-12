import '../repositories/admin_class_repository.dart';

class UpdateManualAttendanceUsecase {
  final AdminClassRepository repository;

  UpdateManualAttendanceUsecase(this.repository);

  Future<void> call({required String userId, required String status}) async {
    return await repository.updateManualAttendance(
      userId: userId,
      status: status,
    );
  }
}
