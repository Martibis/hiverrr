part of 'subscriptions_bloc.dart';

@immutable
abstract class SubscriptionsState {}

class SubscriptionsInitial extends SubscriptionsState {}

class IsLoading extends SubscriptionsState {
  final bool isLoading;

  IsLoading({this.isLoading = true});
}

class IsError extends SubscriptionsState {
  final String message;
  final dynamic e;

  IsError({required this.e, required this.message});
}

class IsLoaded extends SubscriptionsState {
  final List<SubscriptionModel> subscriptions;
  final bool hasReachedMax;
  final int? nextPageKey;

  IsLoaded(
      {required this.subscriptions,
      required this.hasReachedMax,
      required this.nextPageKey});
}
