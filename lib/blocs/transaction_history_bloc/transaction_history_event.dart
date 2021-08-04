part of 'transaction_history_bloc.dart';

@immutable
abstract class TransactionHistoryEvent {}

class FetchTransactions extends TransactionHistoryEvent {
  final int pageKey;
  final String username;

  FetchTransactions({required this.pageKey, required this.username});
}
