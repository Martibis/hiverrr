part of 'theming_bloc.dart';

@immutable
abstract class ThemingEvent {}

class LoadTheme extends ThemingEvent {}

class SetTheme extends ThemingEvent {
  final bool light;

  SetTheme({required this.light});
}
