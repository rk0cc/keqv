library keqv;

import 'dart:convert';

const KEqVCodec keqv = KEqVCodec();

class KEqVCodec extends Codec<Map<String, String?>, String> {
  final int encodeLeftSpacing;
  final int encodeRightSpacing;

  const KEqVCodec({this.encodeLeftSpacing = 1, this.encodeRightSpacing = 1})
      : assert(encodeLeftSpacing >= 0 && encodeRightSpacing >= 0);

  const KEqVCodec.encodeSpacingBoth({int encodeSpacing = 1})
      : assert(encodeSpacing >= 0),
        this.encodeLeftSpacing = encodeSpacing,
        this.encodeRightSpacing = encodeSpacing;

  const KEqVCodec.encodeNoSpacing()
      : this.encodeLeftSpacing = 0,
        this.encodeRightSpacing = 0;

  @override
  Converter<Map<String, String?>, String> get encoder =>
      KEqVEncoder(encodeLeftSpacing, encodeRightSpacing);

  @override
  Converter<String, Map<String, String?>> get decoder => const KEqVDecoder();
}

class KEqVDecoder extends Converter<String, Map<String, String?>> {
  const KEqVDecoder();

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

      return kv.map((e) => e.trim()).toList();
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

class KEqVEncoder extends Converter<Map<String, String?>, String> {
  final int leftSpacing;
  final int rightSpacing;

  const KEqVEncoder(this.leftSpacing, this.rightSpacing)
      : assert(leftSpacing >= 0 && rightSpacing >= 0);

  @override
  String convert(Map<String, String?> input) => input.entries
      .map((e) =>
          "${e.key}${List.filled(leftSpacing, ' ').join()}=${List.filled(rightSpacing, ' ')}${e.value ?? ''}")
      .join("\n");
}
