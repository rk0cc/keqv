/// A pure Dart library for reading simpliest file data format.
library keqv;

import 'dart:convert';

import 'src/decode.dart';
import 'src/encode.dart';
import 'src/str_escape.dart';

export 'src/str_escape.dart' hide StringNotation;

/// A constant of [KEqVCodec] with default setting.
const KEqVCodec keqv = KEqVCodec._(Quoting.doubleQuote, 1, 1);

/// A [Codec] for handling simpliest file data format: `key=value`.
///
/// This is an example of the data format:
/// ```
/// foo=bar
/// baz=
/// bob = male
/// alice= female
/// ```
///
/// The first `=` symbol will be uses to define key and value, any `=` applied
/// after the first symbol will be recognized as [String] value.
///
/// [KEqVCodec] will be recognized the key and value field with trimmed [String]
/// and [Null] if no value defined for the key.
final class KEqVCodec extends Codec<Map<String, Object?>, String> {
  final Quoting quoting;
  final int leftSpacing;
  final int rightSpacing;

  const KEqVCodec._(this.quoting, this.leftSpacing, this.rightSpacing);

  factory KEqVCodec(
      {Quoting quoting = Quoting.doubleQuote,
      int leftSpacing = 1,
      int rightSpacing = 1}) {
    if (<int>[leftSpacing, rightSpacing].any((element) => element < 0)) {
      throw ArgumentError.value(
          (leftSpacing, rightSpacing),
          "(leftSpacing, rightSpacing)",
          "Spacing value should not be an negative integer.");
    }

    return KEqVCodec._(quoting, leftSpacing, rightSpacing);
  }

  factory KEqVCodec.symmetricSpacing(
          {Quoting quoting = Quoting.doubleQuote, int spacing = 1}) =>
      KEqVCodec(quoting: quoting, leftSpacing: spacing, rightSpacing: spacing);

  const KEqVCodec.noSpacing({this.quoting = Quoting.doubleQuote})
      : leftSpacing = 0,
        rightSpacing = 0;

  @override
  Converter<String, Map<String, Object?>> get decoder => KEqVDecoder();

  @override
  Converter<Map<String, Object?>, String> get encoder =>
      KEqVEncoder(quoting, leftSpacing, rightSpacing);
}
