import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginButtonPressed extends AuthEvent {
  final String nomorInduk;
  final String password;

  const LoginButtonPressed({required this.nomorInduk, required this.password});

  @override
  List<Object> get props => [nomorInduk, password];
}

class LogoutButtonPressed extends AuthEvent {}

class ChangePasswordButtonPressed extends AuthEvent{
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordButtonPressed({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object> get props => [oldPassword, newPassword, confirmPassword];
}