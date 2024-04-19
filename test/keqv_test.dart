import 'package:keqv/keqv.dart';
import 'package:test/test.dart';

void main() {
  group("Parsing", () {
    test("when valid", () {
      const String validFormat = '''foo = bar
val = 1.44
snum = "3.14"
yn = true
''';

      final parsedKeqV = keqv.decode(validFormat);
      expect(parsedKeqV["foo"], allOf(<Matcher>[isA<String>(), equals("bar")]));
      expect(parsedKeqV["val"], allOf(<Matcher>[isA<num>(), equals(1.44)]));
      expect(
          parsedKeqV["snum"], allOf(<Matcher>[isA<String>(), equals("3.14")]));
      expect(parsedKeqV["yn"], isTrue);
    });

    test("when invalid", () {
      const List<String> invalidFormats = [
        'invalid\nvalid = true',
        '=invalid\nvalid = 2'
      ];

      for (String invalidFormat in invalidFormats) {
        expect(() => keqv.decode(invalidFormat), throwsFormatException);
      }
    });
  });

  group("Stringify", () {
    test("normal case", () {
      const mapData = <String, Object?>{
        "alpha": "beta",
        "one": 1,
        "one_str": "1",
        "empty": null
      };
      const expectedStr = '''alpha = beta
one = 1
one_str = "1"
empty = 
''';

      expect(keqv.encode(mapData), equals(expectedStr));
    });

    test("invalid key names", () {
      const List<Map<String, dynamic>> invalidKeyMaps = [
        {"foo-bar": 1},
        {"baz=": "foul"},
        {"baz_!!": null}
      ];

      for (Map<String, dynamic> m in invalidKeyMaps) {
        expect(() => keqv.encode(m), throwsArgumentError);
      }
    });

    test("non-primitive types", () {
      final List<Map<String, dynamic>> invalidValueType = [
        {
          "list": [1, 2, 3]
        },
        {
          "set": {"d", "e", "f"}
        },
        {"datetime": DateTime(2024)}
      ];

      for (Map<String, dynamic> m in invalidValueType) {
        expect(() => keqv.encode(m), throwsA(isA<InvalidValueTypeError>()));
      }
    });
  });
}
