import 'dart:convert';

import 'package:meta/meta.dart';

import 'exception.dart';
import 'str_escape.dart';

/// Encoder section for converting [Map] to [String] notation.
@internal
final class KEqVEncoder extends Converter<Map<String, dynamic>, String> {
  final EscapedCharCodec _escChar;

  /// Spacing between key and equal sign.
  final int keySpacing;

  /// Spacing between equal sign and value.
  final int valueSpacing;

  /// Create [KEqVEncoder].
  KEqVEncoder(Quoting quoting, this.keySpacing, this.valueSpacing)
      : _escChar = EscapedCharCodec(quoting: quoting);

  static bool _isValidValueType(Object? value) =>
      value == null || value is num || value is bool || value is String;

  void _assembleEntry(StringBuffer buf, MapEntry<String, Object?> entry) {
    KEqVThrowable.verifyKeyPattern(entry.key);

    buf
      ..write(entry.key)
      ..write(r" " * keySpacing)
      ..write("=")
      ..write(r" " * valueSpacing);

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
