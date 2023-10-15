import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

const SEQUENCE_LENGTH = 64;
const VOCAB_SIZE = 50257;
const NUM_HEAD = 12;
const NUM_LITE_THREADS = 4;

const PROMPTS = [
  "Before boarding your rocket to Mars, remember to pack these items",
  "In a shocking finding, scientist discovered a herd of unicorns living in a remote, previously unexplored valley, in the Andes Mountains. Even more surprising to the researchers was the fact that the unicorns spoke perfect English.",
  "Legolas and Gimli advanced on the orcs, raising their weapons with a harrowing war cry.",
  "Today, scientists confirmed the worst possible outcome: the massive asteroid will collide with Earth",
  "Hugging Face is a company that releases awesome projects in machine learning because",
];
typedef OnProgressListener = void Function(double completed, double total);

class ModelHandler {
  final modelFile = 'model.tflite';
  final labelFile = 'assets/merges.txt';
  final vocabFile = 'assets/vocab.json';

  bool _end = false;
  late Interpreter _interpreter;

  String _prompt = PROMPTS[Random().nextInt(4)];

  // Tokenizer tokenizer;
  // String _completion = '';

  String get prompt {
    return _prompt;
  }

  // String get completion {
  //   return _completion;
  // }

  Future<void> init() async {
    // final bpeRanks = await loadBpeRanks();
    // final encoder = await loadEncoder();
    // final decoder = encoder.map((key, value) => MapEntry(value, key));

    // tokenizer = Tokenizer(decoder, encoder, bpeRanks);
    await loadModel();
  }

  // void launchAutocomplete() async {
  //   _end = false;
  //   final tokens = tokenizer.encode(_prompt);

  //   for (int i = 0; i < 100; i++) {
  //     final decodedToken = generate(tokens);
  //     await Future(() {
  //       _completion = _completion + decodedToken;
  //       notifyListeners();
  //     }).then((value) {
  //       print('completion $_completion');
  //     });
  //     if (_end) {
  //       _end = false;
  //       _completion = '';
  //       notifyListeners();
  //       break;
  //     }
  //   }
  // }

  List<int> generate(List<int> tokens) {
    final maxTokens = tokens.length > SEQUENCE_LENGTH
        ? tokens.getRange(0, SEQUENCE_LENGTH).toList()
        : tokens;
    final paddedTokens = maxTokens +
        List<int>.filled(
          SEQUENCE_LENGTH - maxTokens.length,
          0,
          growable: true,
        );
    final inputIds = [paddedTokens];
    final predictions = List.filled(
        1, List.filled(SEQUENCE_LENGTH, List<double>.filled(VOCAB_SIZE, 0.0)));

    final output = {0: predictions};

    _interpreter.runForMultipleInputs(inputIds, output);

    final outputLogits = predictions[0][maxTokens.length - 1];
    final temp = outputLogits.asMap();
    var sortedKeys = temp.keys.toList(growable: false)
      ..sort((k1, k2) => temp[k2]!.compareTo(temp[k1]!));
    final Map<int, double> sortedMap = {};
    for (final key in sortedKeys.take(40)) {
      sortedMap[key] = temp[key]!;
    }

    final filteredLogitsWithIndexes =
        sortedMap.entries.map((e) => {e.key: e.value}).toList();
    print('filteredLogitsWithIndexes: ${filteredLogitsWithIndexes.length}');
    final filteredLogits =
        filteredLogitsWithIndexes.map((e) => e.values.first).toList();
    final maxLogitValue = filteredLogits.reduce(max);
    final logitsExp =
        filteredLogits.map((e) => exp(e - maxLogitValue)).toList();
    final sumExp = logitsExp.reduce((value, element) => value + element);
    final probs = logitsExp.map((e) => e / sumExp).toList();

    final logitsIndexes =
        filteredLogitsWithIndexes.map((e) => e.keys.first).toList();

    final int nextToken = sample(logitsIndexes, probs);

    tokens.add(nextToken);
    // final decodedToken = tokenizer.decode([nextToken]);

    return [nextToken];
  }

  Future<void> loadModel() async {
    var interpreterOptions = InterpreterOptions()..threads = NUM_LITE_THREADS;

    _interpreter = await Interpreter.fromAsset(
      modelFile,
      options: interpreterOptions,
    );
  }

  Future<Map<String, int>> loadEncoder() async {
    final vocab = await rootBundle.loadString(vocabFile);
    final vocabList = json.decode(vocab);
    return Map<String, int>.from(vocabList);
  }

  Future<Map<Map<String, String>, int>> loadBpeRanks() async {
    Map<Map<String, String>, int> _bpeRanks = {};
    final data = await rootBundle.load('assets/merges.txt');
    final directory = (await getApplicationDocumentsDirectory()).path;
    final file = await writeToFile(data, '$directory/data.txt');
    List<String> lines = await file.readAsLines();

    for (int i = 0; i < lines.length; i++) {
      final list = lines[i].split(' ');
      final keyTuple = {list[0]: list[1]};
      _bpeRanks[keyTuple] = i;
    }
    return _bpeRanks;
  }

  Future<File> writeToFile(ByteData data, String path) {
    return File(path).writeAsBytes(data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    ));
  }

  int randomIndex(List<double> probs) {
    final rnd = probs.reduce((a, b) => a + b) * Random().nextDouble();
    var acc = 0.0;

    for (int i = 0; i < probs.length - 1; i++) {
      acc += probs[i];
      if (rnd < acc) {
        return i;
      }
    }
    return probs.length - 1;
  }

  int sample(List<int> indexs, List<double> probs) {
    final i = randomIndex(probs);
    return indexs[i];
  }

  int argmax(List<double> list) {
    int bestIndex = 0;
    for (int i = 0; i < list.length; i++) {
      if (list[i] > list[bestIndex]) {
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  String refreshPrompt() {
    _end = true;
    _prompt = PROMPTS[Random().nextInt(4)];
    return _prompt;
    // launchAutocomplete();
  }

  void close() {
    _interpreter.close();
  }
}
