import '../repositories/admin_class_repository.dart';

class GetClassesUsecase {
  final AdminClassRepository repository;

  GetClassesUsecase(this.repository);

  Future<Map<String, List<String>>> call() async {
    return await repository.getAvailableClasses();
  }
}