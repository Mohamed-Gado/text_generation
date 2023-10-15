import 'dart:math';

import 'package:text_generation/ml/byte_encoder_decoder.dart';

class Tokenizer {
  final Map<String, int> encoder;
  final Map<int, String> decoder;
  final Map<Map<String, String>, int> bpeRanks;

  Tokenizer(
    this.decoder,
    this.encoder,
    this.bpeRanks,
  );

  final RegExp encodeRegex = RegExp(
    r"""'s|'t|'re|'ve|'m|'ll|'d| ?\d{L}+| ?\d{N}+| ?[^\s\d{L}\d{N}]+|\s+(?!\S)|\s+""",
  );

  String decode(List<int> tokens) {
    final text = tokens.map((e) => decoder[e] ?? '').join();
    final utfCodepoints = text.split('').map((e) => byteDecoder[e] ?? 0);

    return String.fromCharCodes(utfCodepoints, 0, utfCodepoints.length);
  }

  List<int> encode(String text) {
    final tokens = encodeRegex
        .allMatches(text)
        .map(
          (element) => element
              .group(0)!
              .codeUnits
              .map((e) => byteEncoder[e])
              .toList()
              .join(),
        )
        .toList();
    return tokens
        .map((e) => [e])
        .toList()
        .map((e) => encoder[e.first] ?? 0)
        .toList();
  }

  List<String> bpe(String token) {
    if (token.length <= 1) {
      return [token];
    }

    var word = token.split('');
    var pairs = _getPairs(word);

    while (true) {
      for (final pair in pairs.entries) {
        if (!bpeRanks.containsKey(pair)) break;
      }
      final indexs = bpeRanks.entries
          .map((e) => pairs.entries.contains(e.key) ? e.value : -1)
          .toList();
      final pair = bpeRanks.entries
          .firstWhere((element) => element.value == indexs.reduce(max))
          .key;
      var i = 0;
      List<String> newWords = [];
      while (i < word.length) {
        final item = word.firstWhere((element) =>
            word.indexOf(element) >= i && element == pair.keys.first);

        final j = word.indexOf(item);
        if (j != -1) {
          newWords.addAll(word.sublist(i, j));
          i = j;
        } else {
          newWords.addAll(word.sublist(i, word.length));
          break;
        }

        if (word[i] == pair.keys.first &&
            i < word.length - 1 &&
            word[i + 1] == pair.values.first) {
          newWords.add(pair.keys.first + pair.values.first);
          i += 2;
        } else {
          newWords.add(word[i]);
          i += 1;
        }
      }
      word = newWords;
      if (word.length == 1) {
        break;
      } else {
        pairs = _getPairs(word);
      }
    }
    return word;
  }

  Map<String, String> _getPairs(List<String> word) {
    Map<String, String> pairs = {};
    for (int i = 0; i < word.length - 1; i++) {
      pairs[word[i]] = word[i + 1];
    }
    return pairs;
  }
}
