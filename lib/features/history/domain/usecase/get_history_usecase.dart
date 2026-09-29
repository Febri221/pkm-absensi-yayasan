import '../entities/history_entity.dart';
import '../repositories/history_repository.dart';

class GetHistoryUsecase {
  final HistoryRepository repositories;

  GetHistoryUsecase(this.repositories);

  Future<List<HistoryEntity>> call() async {
    return await repositories.getAttendanceHistory();
  }
}