import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../ml/model_handler.dart';
import '../ml/tokenizer.dart';
import '../utils/locator.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ModelHandler _modelHandler = locator<ModelHandler>();
  late Tokenizer tokenizer;
  String _completion = '';
  String _prompt = '';

  HomeBloc() : super(HomeLoadingState()) {
    on<HomeInitEvent>((event, emit) => emit(HomeLoadingState()));
    on<HomeTextGenerationEvent>(
        (event, emit) => emit(HomeTextGenerationState(_prompt, _completion)));
    on<HomeChangePrompt>(
        (event, emit) => emit(HomeInitState(_prompt, _completion)));
  }

  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    yield HomeLoadingState();
    if (event is HomeInitEvent) {
      _prompt = _modelHandler.prompt;
      final bpeRanks = await _modelHandler.loadBpeRanks();
      final encoder = await _modelHandler.loadEncoder();
      final decoder = encoder.map((key, value) => MapEntry(value, key));

      tokenizer = Tokenizer(decoder, encoder, bpeRanks);
      await _modelHandler.init();
      yield HomeInitState(_prompt, _completion);
    } else if (event is HomeTextGenerationEvent) {
      final tokens = tokenizer.encode(_modelHandler.prompt);
      for (int i = 0; i < 100; i++) {
        final decodedToken = _modelHandler.generate(tokens);
        final generatedWord = tokenizer.decode(decodedToken);
        _completion = _completion + generatedWord;
        print(_completion);
        yield HomeTextGenerationState(_prompt, _completion);
      }
    } else if (event is HomeChangePrompt) {
      _prompt = _modelHandler.refreshPrompt();
      yield HomeInitState(_prompt, _completion);
    }
  }
}
