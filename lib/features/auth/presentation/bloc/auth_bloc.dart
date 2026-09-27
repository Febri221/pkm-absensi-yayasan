import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/usecase/login_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUsecase;

  AuthBloc({required this.loginUsecase}) : super(AuthInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      emit(AuthLoading());

      try {
        await loginUsecase(
          nomorInduk: event.nomorInduk,
          password: event.password,
        );
        emit(AuthAuthenticated());
      } catch (e) {
        emit(AuthError(e.toString().replaceAll('Exception: ', "")));
      }
    });
  }
}
