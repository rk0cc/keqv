import 'package:keqv/keqv.dart';
import 'package:test/test.dart';

void main() {
  test("Parsing", () {
    const String validFormat = '''foo = bar
val = 1.44
snum = "3.14"
yn = true
''';

    const String invalidFormat = '''invalid
valid = true
''';

    expect(() => keqv.decode(invalidFormat), throwsFormatException);

    final parsedKeqV = keqv.decode(validFormat);
    expect(parsedKeqV["foo"], isA<String>());
    expect(parsedKeqV["val"], isA<num>());
    expect(parsedKeqV["snum"], isA<String>());
    expect(parsedKeqV["yn"], isTrue);
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
        {"list": [1,2,3]},
        {"set": {"d", "e", "f"}},
        {"datetime": DateTime(2024)}
      ];
      
      for (Map<String, dynamic> m in invalidValueType) {
        expect(() => keqv.encode(m), throwsA(isA<InvalidValueTypeError>()));
      }
    });
  });
}
