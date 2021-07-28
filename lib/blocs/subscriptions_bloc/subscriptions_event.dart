part of 'subscriptions_bloc.dart';

@immutable
abstract class SubscriptionsEvent {}

class FetchSubscriptions extends SubscriptionsEvent {
  final int pageKey;
  final String username;

  FetchSubscriptions({required this.pageKey, required this.username});
}
