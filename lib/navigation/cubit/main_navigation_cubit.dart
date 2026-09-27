import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'main_navigation_state.dart';

class MainNavigationCubit extends Cubit<int> {
  MainNavigationCubit() : super(0);

  void switchTab(int newIndex) {
    emit(newIndex);
  }
}
