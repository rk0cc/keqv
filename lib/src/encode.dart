import 'dart:convert';

import 'package:meta/meta.dart';

import 'exception.dart';
import 'str_escape.dart';

@internal
final class KEqVEncoder extends Converter<Map<String, dynamic>, String> {
  final EscapedCharCodec _escChar;
  final int leftSpacing;
  final int rightSpacing;

  KEqVEncoder(Quoting quoting, this.leftSpacing, this.rightSpacing)
      : _escChar = EscapedCharCodec(quoting: quoting);

  static bool _isValidValueType(Object? value) =>
      value == null || value is num || value is bool || value is String;

  void _assembleEntry(StringBuffer buf, MapEntry<String, Object?> entry) {
    KEqVThrowable.verifyKeyPattern(entry.key);

    buf
      ..write(entry.key)
      ..write(r" " * leftSpacing)
      ..write("=")
      ..write(r" " * rightSpacing);

    if (entry.value != null) {
      buf.write(entry.value is String
          ? _escChar.encode(entry.value as String)
          : entry.value);
    }
  }

  @override
  String convert(Map<String, dynamic> input) {
    if (!input.values.every(_isValidValueType)) {
      final Iterable<String> invalidKeys = input.entries
          .where((element) => !_isValidValueType(element.value))
          .map((e) => e.key);

      KEqVThrowable.throwInvalidValueTypeError(invalidKeys);
    }

    final StringBuffer buf = StringBuffer();

    for (MapEntry<String, dynamic> entry in input.entries) {
      _assembleEntry(buf, entry);
      buf.writeln();
    }

    return buf.toString();
  }
}
