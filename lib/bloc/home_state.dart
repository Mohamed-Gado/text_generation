part of 'home_bloc.dart';

@immutable
abstract class HomeState {
  const HomeState();
}

class HomeLoadingState extends HomeState {
  const HomeLoadingState();
}

class HomeTextGenerationState extends HomeState {
  final String prompt;
  final String completion;
  const HomeTextGenerationState(
    this.prompt,
    this.completion,
  );
}

class HomeInitState extends HomeState {
  final String prompt;
  final String completion;
  const HomeInitState(
    this.prompt,
    this.completion,
  );
}
