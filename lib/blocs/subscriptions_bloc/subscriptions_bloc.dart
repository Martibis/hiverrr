import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hiverrr/constants/constants.dart';
import 'package:hiverrr/data/models/subscription_model.dart';
import 'package:meta/meta.dart';

part 'subscriptions_event.dart';
part 'subscriptions_state.dart';

class SubscriptionsBloc extends Bloc<SubscriptionsEvent, SubscriptionsState> {
  SubscriptionsBloc() : super(SubscriptionsInitial());
  final int limit = 50;
  List<SubscriptionModel> subscriptions = [];
  bool hasReachedMax = false;
  int? nextPageKey;

  @override
  Stream<SubscriptionsState> mapEventToState(
    SubscriptionsEvent event,
  ) async* {
    if (event is FetchSubscriptions) {
      yield IsLoading(isLoading: true);
      try {
        List<SubscriptionModel> newSubscriptions = await hc.getSubscriptions(
            username: event.username, pageKey: event.pageKey, limit: limit);

        subscriptions = [...subscriptions, ...newSubscriptions];

        if (event.pageKey == 0) {
          subscriptions = newSubscriptions;
        }

        hasReachedMax = newSubscriptions.length < limit;
        nextPageKey = hasReachedMax ? null : limit + newSubscriptions.length;

        yield IsLoaded(
            subscriptions: subscriptions,
            hasReachedMax: hasReachedMax,
            nextPageKey: nextPageKey);
      } catch (e) {
        print(e);
        yield IsError(e: e, message: 'Error when loading more');
      }
    }
  }
}
