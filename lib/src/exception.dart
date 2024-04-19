import 'package:meta/meta.dart';

/// A subclass of [TypeError] that the given [Map] contains
/// invalid values type when encoding.
final class InvalidValueTypeError extends TypeError {
  /// A sequence of [Map.keys], which assigned with
  /// invalid value.
  final Iterable<String> keys;

  /// Message of this error.
  final String message;

  InvalidValueTypeError._(this.keys, this.message);

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

/// Perform throwing [Error] and [Exception] functions calling.
@internal
final class KEqVThrowable {
  const KEqVThrowable._();

  /// Proxy caller for throwing [InvalidValueTypeError].
  static Never throwInvalidValueTypeError(Iterable<String> keys,
      [String message =
          "All values should use primitive data type, but non-primitive type found in the map."]) {
    throw InvalidValueTypeError._(keys, message);
  }

  /// Verify [key] naming pattern. If it is invalid, throws [ArgumentError].
  static void verifyKeyPattern(String key) {
    if (key.contains(RegExp(r'[\^*.\[\]{}()?\-"!@#%&/\,><:;~`+=' "'" ']'))) {
      throw ArgumentError.value(
          key, "entry.key", "One of the keys contains invalid characters");
    }
  }
}
