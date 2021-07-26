part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class InitialState extends AuthState {}

class Loading extends AuthState {
  final bool isLoading;
  Loading({this.isLoading = false});
}

class LoggedIn extends AuthState {
  final User user;

  LoggedIn({required this.user});
}

class Error extends AuthState {
  final String message;
  final dynamic e;
  final bool firstTime;

  Error({this.e, required this.message, this.firstTime = false});
}
