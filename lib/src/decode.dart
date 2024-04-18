import 'dart:convert';

import 'package:meta/meta.dart';

import 'str_escape.dart';

typedef _PairRow = ({String key, String value});

/// Handle [KEqVCodec] convert from [String] to corresponded [Map].
@internal
final class KEqVDecoder extends Converter<String, Map<String, dynamic>> {
  final EscapedCharCodec _escChar = const EscapedCharCodec();

  /// Construct a decoder.
  KEqVDecoder();

  _PairRow _readLine(String line) {
    int equalPos = 0;

    for (; equalPos < line.length; equalPos++) {
      if (line[equalPos] == "=") {
        break;
      }
    }

    if (equalPos >= line.length) {
      throw FormatException("Incompleted statement content found", line);
    }

    return (
      key: line.substring(0, equalPos).trim(),
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

    if (decValue.useQuote) {
      return decValue.substring(1, decValue.length - 1);
    }

    try {
      return num.parse(decValue);
    } on FormatException {}

    try {
      return bool.parse(decValue);
    } on FormatException {}

    return decValue;
  }

  @override
  Map<String, dynamic> convert(String input) {
    final Iterable<_PairRow> pairRow = LineSplitter.split(input).map(_readLine);

    return <String, dynamic>{
      for (var (key: k, value: v) in pairRow) k: _parseValue(v)
    };
  }
}
