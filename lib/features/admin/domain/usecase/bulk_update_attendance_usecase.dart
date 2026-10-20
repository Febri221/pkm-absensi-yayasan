import '../repositories/admin_class_repository.dart';

class BulkUpdateAttendanceUsecase {
  final AdminClassRepository repository;

  BulkUpdateAttendanceUsecase(this.repository);

  Future<void> call({
    required List<String> userIds,
    required String status,
  }) async {
    return await repository.bulkUpdateAttendance(
      userIds: userIds,
      status: status,
    );
  }
}
