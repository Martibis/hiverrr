part of 'transaction_history_bloc.dart';

@immutable
abstract class TransactionHistoryState {}

class TransactionHistoryInitial extends TransactionHistoryState {}

class IsLoading extends TransactionHistoryState {
  final bool isLoading;

  IsLoading({this.isLoading = true});
}

class IsError extends TransactionHistoryState {
  final String message;
  final dynamic e;

  IsError({required this.e, required this.message});
}

class IsLoaded extends TransactionHistoryState {
  final List<TransactionModel> transactions;
  final bool hasReachedMax;
  final int? nextPageKey;

  IsLoaded(
      {required this.transactions,
      required this.hasReachedMax,
      required this.nextPageKey});
}
