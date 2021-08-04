import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hiverrr/constants/constants.dart';
import 'package:hiverrr/data/models/transaction_model.dart';
import 'package:meta/meta.dart';

part 'transaction_history_event.dart';
part 'transaction_history_state.dart';

class TransactionHistoryBloc
    extends Bloc<TransactionHistoryEvent, TransactionHistoryState> {
  TransactionHistoryBloc() : super(TransactionHistoryInitial());

  final int limit = 100;
  List<TransactionModel> transactions = [];
  bool hasReachedMax = false;
  int? nextPageKey;

  @override
  Stream<TransactionHistoryState> mapEventToState(
    TransactionHistoryEvent event,
  ) async* {
    if (event is FetchTransactions) {
      yield IsLoading(isLoading: true);
      try {
        List<TransactionModel> newTransactions = await hc.getTransactionHistory(
            username: event.username, start: event.pageKey, limit: limit);
        transactions = [...transactions, ...newTransactions];

        if (event.pageKey == -1) {
          transactions = newTransactions;
        }

        if (newTransactions.length == 0) {
          hasReachedMax = true;
        }

        nextPageKey = hasReachedMax ? null : newTransactions.last.count - 1;

        yield IsLoaded(
            transactions: transactions,
            hasReachedMax: hasReachedMax,
            nextPageKey: nextPageKey);
      } catch (e) {
        print(e);
        yield IsError(e: e, message: 'Error when loading more');
      }
    }
  }
}
