import 'package:sistem_absensi_sekolah/features/auth/domain/usecase/change_password_usecase.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/usecase/login_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUsecase;
  final ChangePasswordUsecase changePasswordUsecase;

  AuthBloc({required this.loginUsecase, required this.changePasswordUsecase})
    : super(AuthInitial()) {
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

    on<ChangePasswordButtonPressed>((event, emit) async {
      emit(AuthLoading());

      try {
        await changePasswordUsecase(
          oldPassword: event.oldPassword,
          newPassword: event.newPassword,
          confirmPassword: event.confirmPassword,
        );
        emit(const PasswordChangedSuccess("Kata sandi berhasil diubah! "));
      } catch (e) {
        emit(AuthError(e.toString().replaceAll('Exception', '')));
      }
    });
  }
}
