import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:hiverrr/constants/constants.dart';
import 'package:meta/meta.dart';

part 'theming_event.dart';
part 'theming_state.dart';

class ThemingBloc extends Bloc<ThemingEvent, ThemingState> {
  ThemingBloc() : super(ThemingInitial());
  bool light = true;

  @override
  Stream<ThemingState> mapEventToState(
    ThemingEvent event,
  ) async* {
    if (event is SetTheme) {
      yield ThemingInitial();
      light = event.light;
      String value = light ? 'true' : 'false';
      await STORAGE.write(key: 'light-theme', value: value);
      yield ThemeLoaded(light: light);
    }
    if (event is LoadTheme) {
      yield ThemingInitial();
      String? lightTheme = await STORAGE.read(key: 'light-theme');

      if (lightTheme == null) {
        Brightness brightness =
            SchedulerBinding.instance!.window.platformBrightness;
        if (brightness == Brightness.light) {
          light = true;
        }
        if (brightness == Brightness.dark) {
          light = false;
        }
      } else {
        if (lightTheme == "true") {
          light = true;
        }
        if (lightTheme == "false") {
          light = false;
        }
      }
      yield ThemeLoaded(light: light);
    }
  }
}
