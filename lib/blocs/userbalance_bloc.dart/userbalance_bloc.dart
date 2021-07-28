import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hiverrr/constants/constants.dart';
import 'package:hiverrr/data/hive_calls/hive_calls.dart';
import 'package:hiverrr/data/models/user_balance_model.dart';
import 'package:meta/meta.dart';

part 'userbalance_event.dart';
part 'userbalance_state.dart';

class UserbalanceBloc extends Bloc<UserbalanceEvent, UserbalanceState> {
  UserbalanceBloc() : super(UserbalanceInitial());

  @override
  Stream<UserbalanceState> mapEventToState(
    UserbalanceEvent event,
  ) async* {
    if (event is GetUserBalance) {
      yield UserBalanceLoading(isLoading: true);
      try {
        UserBalance userBalance =
            await hc.getUserBalance(username: event.username);
        yield UserBalancedLoaded(userBalance: userBalance);
      } catch (e) {
        print(e);
        UserBalanceError(
            message: 'Something went wrong when trying to get your balance.',
            e: e);
      }
    }
  }
}
