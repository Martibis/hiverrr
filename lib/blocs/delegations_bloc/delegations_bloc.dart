import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hiverrr/constants/constants.dart';
import 'package:hiverrr/data/models/delegation_model.dart';
import 'package:meta/meta.dart';

part 'delegations_event.dart';
part 'delegations_state.dart';

class DelegationsBloc extends Bloc<DelegationsEvent, DelegationsState> {
  DelegationsBloc() : super(DelegationsInitial());

  final int limit = 50;
  List<DelegationModel> delegations = [];
  bool hasReachedMax = false;
  bool expiringReachedMax = false;
  bool activeReachedMax = false;
  int? nextPageKey;

  @override
  Stream<DelegationsState> mapEventToState(
    DelegationsEvent event,
  ) async* {
    if (event is FetchDelegations) {
      yield IsLoading(isLoading: true);
      if (event.isRefresh) {
        hasReachedMax = false;
        expiringReachedMax = false;
        activeReachedMax = false;
        delegations = [];
      }
      try {
        List<DelegationModel> newDelegations = [];
        if (!expiringReachedMax) {
          List<DelegationModel> expiringDelegations =
              await hc.getExpiringDelegations(
                  username: event.username,
                  pageKey: event.pageKey,
                  limit: limit,
                  vestsToHive: event.vestsToHive);
          newDelegations = [...newDelegations, ...expiringDelegations];

          expiringReachedMax = expiringDelegations.length < limit;
          if (expiringReachedMax) {
            nextPageKey = 0;
          }
        }

        if (expiringReachedMax && !activeReachedMax) {
          List<DelegationModel> activeDelegations = await hc.getDelegations(
              username: event.username,
              pageKey: event.pageKey,
              limit: limit,
              vestsToHive: event.vestsToHive);

          newDelegations = [...newDelegations, ...activeDelegations];
          activeReachedMax = activeDelegations.length < limit;

          nextPageKey = activeReachedMax ? null : (nextPageKey! + limit);
        }

        delegations = [...delegations, ...newDelegations];

        if (expiringReachedMax && activeReachedMax) {
          hasReachedMax = true;
        } else {
          hasReachedMax = false;
        }

        yield IsLoaded(
            delegations: delegations,
            hasReachedMax: hasReachedMax,
            nextPageKey: nextPageKey);
      } catch (e) {
        print(e);
        yield IsError(e: e, message: 'Error when loading more');
      }
    }
  }
}
