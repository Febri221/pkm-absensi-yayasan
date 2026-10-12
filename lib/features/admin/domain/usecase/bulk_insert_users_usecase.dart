import '../repositories/admin_class_repository.dart';

class BulkInsertUsersUsecase {
  final AdminClassRepository repository;

  BulkInsertUsersUsecase(this.repository);

  Future<void> call(String csvStringContent) async {
    return await repository.bulkInsertUsersFromCsv(csvStringContent);
  }
}