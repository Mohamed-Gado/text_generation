part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {
  const HomeEvent();
}

class HomeTextGenerationEvent extends HomeEvent {
  const HomeTextGenerationEvent();
}

class HomeInitEvent extends HomeEvent {
  const HomeInitEvent();
}

class HomeChangePrompt extends HomeEvent {
  const HomeChangePrompt();
}
