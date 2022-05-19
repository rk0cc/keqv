import 'package:keqv/keqv.dart';
import 'package:test/test.dart';

void main() {
  group("Read data", () {
    test("from String directly", () {
      const String testData = '''
foo=bar
i=1
''';
      Map<String, String?> decoded = keqv.decode(testData);
      expect(decoded["foo"], equals("bar"));
      expect(decoded["i"], "1");
    });
  });
}
