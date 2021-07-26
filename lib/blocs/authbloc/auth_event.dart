part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class TryLogInFromToken extends AuthEvent {}

class HiveLogin extends AuthEvent {
  final String username;

  HiveLogin({required this.username});
}

class LogOut extends AuthEvent {}
