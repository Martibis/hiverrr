part of 'theming_bloc.dart';

@immutable
abstract class ThemingState {}

class ThemingInitial extends ThemingState {}

class ThemeLoaded extends ThemingState {
  final bool light;

  ThemeLoaded({this.light = true});
}
