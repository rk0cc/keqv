/// Simplest key-value pair [Codec] for converting between [Map] and [String].
library keqv;

import 'dart:convert';

import 'src/decode.dart';
import 'src/encode.dart';
import 'src/exception.dart' show InvalidValueTypeError;
import 'src/str_escape.dart';

export 'src/exception.dart' show InvalidValueTypeError;
export 'src/str_escape.dart' hide StringNotation;

/// Convert [KEqVCodec] encoded content from [String] to bytes using
/// [Encoding] and vice versa.
typedef KEqVBinarizer = Codec<Map<String, dynamic>, List<int>>;

/// A [Codec] responsable for compressing byte data.
typedef Compressor = Codec<List<int>, List<int>>;

/// A constant [KEqVCodec] with equivalent default preference from
/// [KEqVCodec.new].
const KEqVCodec keqv = KEqVCodec._(Quoting.doubleQuote, 1, 1);

/// A [Codec] for handling simpliest file data format: `key=value`.
///
/// The name of keys must be an alphanumeric [String] with space,
/// `$` and `_`. Any invalid characters found causes throwing
/// [ArgumentError].
///
/// This is an example of the data format:
/// ```text
/// foo=bar
/// baz=
/// bob = male
/// alice= female
/// number =  3
/// esc_num = "3"
/// is_dart    =true
/// ```
///
/// [KEqVCodec] will be recognized the key and value field with trimmed [String].
/// Then, it will convert to [num], [bool], [String] and [Null] depending on
/// which values will be convert to [String] with character escape staregy
/// from JSON. Therefore, the given [Map]'s values must satisified those four
/// primitive type of Dart or throw [InvalidValueTypeError] when [encode].
///
/// During [decode], it expects that every lines contain at least one equal
/// sign, which the first one will be used to identify key and value.
/// A valid satement must contains name of key, equal symbol and
/// value (optional) in a sequence. If incompleted statements existed,
/// it throws [FormatException].
final class KEqVCodec extends Codec<Map<String, dynamic>, String> {
  /// Forbidden [Encoding.name] uses for [binarizer].
  static const Set<String> _encodingBlacklist = {"system"};

  /// Apply quoting symbol to prevent [String] value parsed to
  /// another type.
  final Quoting quoting;

  /// Define spacing between key and equal sign.
  final int keySpacing;

  /// Define spacing between equal sign and value.
  final int valueSpacing;

  const KEqVCodec._(this.quoting, this.keySpacing, this.valueSpacing);

  /// Create [KEqVCodec] instance and specified preferences during [encode].
  ///
  /// The [quoting] can be [Quoting.singleQuote] or [Quoting.doubleQuote] to
  /// esacpes [String] that it prevents parsing the [String] to another
  /// data type.
  ///
  /// Apply [keySpacing] and [valueSpacing] will affects padding spaces on
  /// equal symbol. It should be non-negative [int] with default value as `1`.
  /// [ArgumentError] will be thrown if attempted to assign negative [int].
  ///
  /// It is encouraged to uses [keqv] constant if no preferences need to be
  /// changed.
  factory KEqVCodec(
      {Quoting quoting = Quoting.doubleQuote,
      int keySpacing = 1,
      int valueSpacing = 1}) {
    if (<int>[keySpacing, valueSpacing].any((element) => element < 0)) {
      throw ArgumentError.value(
          (keySpacing, valueSpacing),
          "(keySpacing, valueSpacing)",
          "Spacing value should not be an negative integer.");
    }

    return KEqVCodec._(quoting, keySpacing, valueSpacing);
  }

  /// Apply same [spacing] surrounded by equal sign when [encode].
  factory KEqVCodec.symmetricSpacing(
          {Quoting quoting = Quoting.doubleQuote, int spacing = 1}) =>
      KEqVCodec(quoting: quoting, keySpacing: spacing, valueSpacing: spacing);

  /// Create [KEqVCodec] that no spacing applied.
  const KEqVCodec.noSpacing({this.quoting = Quoting.doubleQuote})
      : keySpacing = 0,
        valueSpacing = 0;

  /// [fuse] from [String] to byte with provided [Encoding].
  ///
  /// The [encoding] should only handle one [Encoding] method without
  /// any conditions applied. Otherwise, it throws [UnsupportedError].
  /// 
  /// Optinally, it can specify [compressor] if data compression is required.
  static KEqVBinarizer binarizer(Encoding encoding,
      {Compressor? compressor,
      Quoting quoting = Quoting.doubleQuote,
      int keySpacing = 1,
      int valueSpacing = 1}) {
    if (_encodingBlacklist.contains(encoding.name)) {
      throw UnsupportedError("This encoding method has been blacklisted.");
    }

    KEqVBinarizer binarizer = KEqVCodec._(quoting, keySpacing, valueSpacing).fuse(encoding);

    if (compressor != null) {
      binarizer = binarizer.fuse(compressor);
    }

    return binarizer;
  }

  @override
  Converter<String, Map<String, dynamic>> get decoder => KEqVDecoder();

  @override
  Converter<Map<String, dynamic>, String> get encoder =>
      KEqVEncoder(quoting, keySpacing, valueSpacing);
}
