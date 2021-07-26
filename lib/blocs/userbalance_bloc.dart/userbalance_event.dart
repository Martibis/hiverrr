part of 'userbalance_bloc.dart';

@immutable
abstract class UserbalanceEvent {}

class GetUserBalance extends UserbalanceEvent {
  final String username;

  GetUserBalance({required this.username});
}
