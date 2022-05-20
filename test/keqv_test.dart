import 'package:keqv/keqv.dart';
import 'package:test/test.dart';

void main() {
  group("Read data", () {
    test("from String directly", () {
      const String testData = '''
foo=bar
i=1
bin=
''';
      Map<String, String?> decoded = keqv.decode(testData);
      expect(decoded["foo"], equals("bar"));
      expect(decoded["i"], equals("1"));
      expect(decoded["baz"], isNull);
      expect(decoded["bin"], isNull);
      expect(decoded.containsKey("bin"), isTrue);
    });
  });
}
