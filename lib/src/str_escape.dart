import 'dart:convert';

import 'package:meta/meta.dart';

enum Quoting {
  singleQuote(r"'"),
  doubleQuote(r'"');

  final String quote;

  const Quoting(this.quote);
}

@internal
extension StringNotation on String {
  (String, String) get wrappedChar => (this[0], this[length - 1]);

  bool get canBeParsed {
    try {
      num.parse(this);
      bool.parse(this);
    } on FormatException {
      return true;
    }

    final (firstChar, lastChar) = wrappedChar;
    final bool isArray = firstChar == r"[" && lastChar == r"]";
    final bool isObject = firstChar == r"{" && lastChar == r"}";

    return isArray || isObject;
  }

  bool get useQuote {
    final (firstChar, lastChar) = wrappedChar;

    final bool isUsingQuote = <String>[
      firstChar,
      lastChar
    ].every((element) => Quoting.values.map((e) => e.quote).contains(element));

    return isUsingQuote && firstChar == lastChar;
  }
}

final class EscapedCharCodec extends Codec<String, String> {
  final Quoting? quoting;

  const EscapedCharCodec({this.quoting});

  @override
  Converter<String, String> get decoder => const _EscapedCharDecoder();

  @override
  Converter<String, String> get encoder => quoting == null
      ? const _EscapedCharEncoder()
      : _EscapedCharEncoder(quoting!);
}

final class _EscapedCharDecoder extends Converter<String, String> {
  const _EscapedCharDecoder();

  @override
  String convert(String input) {
    String decCtx = input;

    if (decCtx.useQuote) {
      decCtx = decCtx.substring(1, decCtx.length - 1);
    }

    return jsonDecode('"$decCtx"');
  }
}

final class _EscapedCharEncoder extends Converter<String, String> {
  final Quoting quoting;

  const _EscapedCharEncoder([this.quoting = Quoting.doubleQuote]);

  @override
  String convert(String input) {
    String encoded = jsonEncode(input);
    encoded = encoded.substring(1, encoded.length - 1);

    if (encoded.canBeParsed) {
      encoded = quoting.quote + encoded + quoting.quote;
    }

    return encoded;
  }
}
