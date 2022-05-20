/// A pure Dart library for reading simpliest file data format.
library keqv;

import 'dart:convert';

/// A constant of [KEqVCodec] with default setting.
const KEqVCodec keqv = KEqVCodec();

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
class KEqVCodec extends Codec<Map<String, String?>, String> {
  /// Define how many space charathers between key and the equal symbol.
  final int encodeLeftSpacing;

  /// Define how many space charathers between value and the equal symbol.
  final int encodeRightSpacing;

  /// Construct a [KEqVCodec].
  ///
  /// Optionally, specify [encodeLeftSpacing] and [encodeRightSpacing] for apply
  /// exported layout of [encode].
  const KEqVCodec({this.encodeLeftSpacing = 1, this.encodeRightSpacing = 1})
      : assert(encodeLeftSpacing >= 0 && encodeRightSpacing >= 0);

  /// Construct a [KEqVCodec] and apply [encodeSpacing] for each side.
  const KEqVCodec.encodeSpacingBoth({int encodeSpacing = 1})
      : assert(encodeSpacing >= 0),
        this.encodeLeftSpacing = encodeSpacing,
        this.encodeRightSpacing = encodeSpacing;

  /// Construct a [KEqVCodec] without spacing when [encode].
  const KEqVCodec.encodeNoSpacing()
      : this.encodeLeftSpacing = 0,
        this.encodeRightSpacing = 0;

  @override
  Converter<Map<String, String?>, String> get encoder =>
      KEqVEncoder._(encodeLeftSpacing, encodeRightSpacing);

  @override
  Converter<String, Map<String, String?>> get decoder => const KEqVDecoder._();
}

/// Handle [KEqVCodec] convert from [String] to corresponded [Map].
class KEqVDecoder extends Converter<String, Map<String, String?>> {
  /// Construct a decoder.
  const KEqVDecoder._();

  @override
  Map<String, String?> convert(String input) {
    List<String> kvrow = input.split(RegExp(r"\r?\n"))
      ..removeWhere((r) => r.isEmpty);

    List<List<String>> row = kvrow.map((e) {
      List<String> kv = e.split("=");

      if (kv[0].trim().isEmpty) {
        throw FormatException(
            "Key can not be empty or whitespace only string", kv[0]);
      }

      return <String>[kv[0], kv.skip(0).join("=")];
    }).toList();

    Iterable<String> k = row.map((e) => e.first);
    Set<String> ks = k.toSet();

    if (k.length != ks.length) {
      Iterable<String> duplicated =
          ks.where((dk) => k.where((rk) => rk == dk).length > 1);

      throw FormatException(
          "Found ${duplicated.length} duplicated key${duplicated.length == 1 ? '' : 's'}.",
          duplicated);
    }

    return <String, String?>{
      for (List<String> kv in row) kv[0]: kv[1].isEmpty ? null : kv[1]
    };
  }
}

/// Handle [KEqVCodec] to siringify [Map].
class KEqVEncoder extends Converter<Map<String, String?>, String> {
  /// Define spacing between key and equal symbol.
  final int _leftSpacing;

  /// Define spacing between value and equal symbol.
  final int _rightSpacing;

  /// Construct a encoder and specify [leftSpacing] and [rightSpacing].
  const KEqVEncoder._(this._leftSpacing, this._rightSpacing)
      : assert(_leftSpacing >= 0 && _rightSpacing >= 0);

  @override
  String convert(Map<String, String?> input) => input.entries
      .map((e) =>
          "${e.key}${List.filled(_leftSpacing, ' ').join()}=${List.filled(_rightSpacing, ' ')}${e.value ?? ''}")
      .join("\n");
}

/// [Map] extension that convert value as [String].
extension KEqVMapConverter<T> on Map<String, T> {
  /// Convert to [Map] for [KEqVCodec].
  Map<String, String?> toKEqVMap() => Map.fromEntries(this.entries.map(
      (e) => MapEntry(e.key, e.value == null ? null : e.value.toString())));
}
