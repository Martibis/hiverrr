part of 'delegations_bloc.dart';

@immutable
abstract class DelegationsEvent {}

class FetchDelegations extends DelegationsEvent {
  final int pageKey;
  final String username;
  final num vestsToHive;
  final bool isRefresh;

  FetchDelegations(
      {required this.pageKey,
      required this.username,
      required this.vestsToHive,
      required this.isRefresh});
}
