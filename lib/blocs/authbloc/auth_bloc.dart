import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hiverrr/constants/constants.dart';
import 'package:hiverrr/data/models/user_model.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial());

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is LogOut) {
      STORAGE.delete(key: 'hive-username');
      //STORAGE.delete(key: 'tos');
      yield InitialState();
    }
    if (event is TryLogInFromToken) {
      yield Loading(isLoading: true);
      try {
        String? username = await STORAGE.read(key: 'hive-username');
        //TODO: call Hivesigner API to log in
        if (username != null) {
          User u = User(
              username: username,
              profilepic: 'https://images.ecency.com/webp/u/' +
                  username +
                  '/avatar/medium');
          yield LoggedIn(user: u);
        } else {
          yield InitialState();
        }
      } catch (e) {
        print(e);
        yield Error(message: 'Error when logging in', e: e, firstTime: true);
      }
    }
    if (event is HiveLogin) {
      yield Loading(isLoading: true);
      try {
        await STORAGE.write(key: 'hive-username', value: event.username);
        User u = User(
            username: event.username,
            profilepic: 'https://images.ecency.com/webp/u/' +
                event.username +
                '/avatar/medium');
        yield LoggedIn(user: u);
      } catch (e) {
        print(e);
        yield Error(message: 'Error when logging in', e: e);
      }
    }
  }
}
