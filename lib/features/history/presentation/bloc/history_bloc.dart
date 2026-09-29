import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecase/get_history_usecase.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistoryUsecase getHistoryUsecase;

  HistoryBloc({required this.getHistoryUsecase}) : super(HistoryInitial()) {
    on<FetchHistoryEvent>((event, emit) async {
      emit(HistoryLoading());

      try {
        final historyData = await getHistoryUsecase();

        emit(HistoryLoaded(historyList: historyData));
      } catch (e) {
        emit(HistoryError(e.toString()));
      }

    });
  }
}