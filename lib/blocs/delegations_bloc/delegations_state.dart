part of 'delegations_bloc.dart';

@immutable
abstract class DelegationsState {}

class DelegationsInitial extends DelegationsState {}

class IsLoading extends DelegationsState {
  final bool isLoading;

  IsLoading({this.isLoading = true});
}

class IsError extends DelegationsState {
  final String message;
  final dynamic e;

  IsError({required this.e, required this.message});
}

class IsLoaded extends DelegationsState {
  final List<DelegationModel> delegations;
  final bool hasReachedMax;
  final int? nextPageKey;

  IsLoaded(
      {required this.delegations,
      required this.hasReachedMax,
      required this.nextPageKey});
}
