import '../entities/history_entity.dart';

abstract class HistoryRepository {
  Future<List<HistoryEntity>> getAttendanceHistory();
}