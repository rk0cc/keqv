import 'dart:convert';

import 'package:meta/meta.dart';

import 'exception.dart';
import 'str_escape.dart';

typedef _PairRow = ({String key, String value});

@internal
final class KEqVDecoder extends Converter<String, Map<String, dynamic>> {
  final EscapedCharCodec _escChar = const EscapedCharCodec();

  KEqVDecoder();

  _PairRow _readLine(String line) {
    int equalPos = 0;

    for (; equalPos < line.length; equalPos++) {
      if (line[equalPos] == "=") {
        break;
      }
    }

    if (equalPos >= line.length || equalPos == 0) {
      throw FormatException("Incompleted statement content found", line);
    }

    final String k = line.substring(0, equalPos).trim();

    KEqVThrowable.verifyKeyPattern(k);

    return (
      key: k,
      value: line.length == equalPos + 1
          ? ""
          : line.substring(equalPos + 1, line.length).trim()
    );
  }

  Object? _parseValue(String value) {
    final String decValue = _escChar.decode(value);

    if (decValue.isEmpty) {
      return null;
    }

    if (value.useQuote) {
      return decValue;
    }

    try {
      return num.parse(decValue);
    } on FormatException {
      try {
        return bool.parse(decValue);
      } on FormatException {
        return decValue;
      }
    }
  }

  @override
  Map<String, dynamic> convert(String input) {
    final Iterable<_PairRow> pairRow = LineSplitter.split(input)
        .where((element) => element.isNotEmpty)
        .map(_readLine);

    return <String, dynamic>{
      for (var (key: k, value: v) in pairRow) k: _parseValue(v)
    };
  }
}
