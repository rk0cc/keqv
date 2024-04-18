import 'dart:convert';

import 'package:meta/meta.dart';

import 'str_escape.dart';

final class InvalidValueTypeError extends TypeError {
  final Iterable<String> keys;
  final String message;

  InvalidValueTypeError._(this.keys,
      // ignore: unused_element
      [this.message =
          "All values should use primitive data type, but non-primitive type found in the map."]);

  @override
  String toString() {
    final StringBuffer buf = StringBuffer();

    buf
      ..write("InvalidValueTypeError: ")
      ..writeln(message)
      ..writeln()
      ..write("\tAssociated keys: [");

    if (keys.length <= 3) {
      buf.write(keys.join(", "));
    } else {
      buf
        ..write(keys.take(3).join(", "))
        ..write(", ...(with ${keys.length - 3} more)");
    }

    buf.writeln("]");

    return buf.toString();
  }
}

/// Handle [KEqVCodec] to siringify [Map].
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
    if (entry.key
        .contains(RegExp(r'[\^*.\[\]{}()?\-"!@#%&/\,><:;~`+=' + "'" + ']'))) {
      throw ArgumentError.value(entry.key, "entry.key",
          "One of the keys contains invalid characters");
    }
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
          .where((element) => _isValidValueType(element.value))
          .map((e) => e.key);
      throw InvalidValueTypeError._(invalidKeys);
    }

    final StringBuffer buf = StringBuffer();

    for (MapEntry<String, dynamic> entry in input.entries) {
      _assembleEntry(buf, entry);
      buf.writeln();
    }

    return buf.toString();
  }
}
