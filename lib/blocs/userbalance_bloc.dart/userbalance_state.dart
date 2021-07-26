part of 'userbalance_bloc.dart';

@immutable
abstract class UserbalanceState {}

class UserbalanceInitial extends UserbalanceState {}

class UserBalanceLoading extends UserbalanceState {
  final bool isLoading;
  UserBalanceLoading({this.isLoading = false});
}

class UserBalancedLoaded extends UserbalanceState {
  final UserBalance userBalance;

  UserBalancedLoaded({required this.userBalance});
}

class UserBalanceError extends UserbalanceState {
  final String message;
  final dynamic e;

  UserBalanceError({required this.message, this.e});
}
