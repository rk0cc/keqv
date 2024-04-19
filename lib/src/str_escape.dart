import 'dart:convert';

import 'package:meta/meta.dart';

/// Determine quoting symbol when the [String] can be used for
/// [num.parse], [bool.parse] and containers symbols for JSON
/// (e.g. `[]` and `{}`).
enum Quoting {
  /// Apply signle quote (`'`) symbol.
  singleQuote(r"'"),

  /// Apply double quote (`"`) symbol.
  doubleQuote(r'"');

  final String _quote;

  const Quoting(this._quote);
}

/// [String] extension for detecting pattern.
@internal
extension StringNotation on String {
  /// Extract the first and last [String]'s character.
  (String, String) get wrappedChar => (this[0], this[length - 1]);

  /// Determine this [String] can be parsed by using [num.parse]
  /// and [bool.parse].
  bool get canBeParsed => [num.tryParse(this), bool.tryParse(this)]
      .any((element) => element != null);

  /// Check this [String] is quoted with [quoting] symbol.
  bool isQuotedWith(Quoting quoting) {
    final (firstChar, lastChar) = wrappedChar;

    return firstChar == quoting._quote && lastChar == quoting._quote;
  }

  /// Check this [String] is quoted.
  bool get useQuote => Quoting.values.any(isQuotedWith);

  String unquote() => useQuote ? substring(1, length - 1) : this;
}

/// Escape all control characters to human readable [String] based
/// on [JsonCodec] as well as denote [String] type when parsable.
final class EscapedCharCodec extends Codec<String, String> {
  /// Define quoting symbol when [encode] with parsable [String].
  final Quoting? quoting;

  /// Create instance of escaping character codec.
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
      encoded = quoting._quote + encoded + quoting._quote;
    }

    return encoded;
  }
}
