import '../repositories/admin_class_repository.dart';

class BulkInsertUsersUsecase {
  final AdminClassRepository repository;

  BulkInsertUsersUsecase(this.repository);

  Future<void> call(String csvString) async {
    if (csvString.isEmpty) {
      throw Exception("Data CSV kosong!");
    }
    return await repository.bulkInsertUsersFromCsv(csvString);
  }
}
