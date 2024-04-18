import 'package:keqv/keqv.dart' show EscapedCharCodec, Quoting;
import 'package:test/test.dart';

void main() {
  const EscapedCharCodec singleQuote =
          EscapedCharCodec(quoting: Quoting.singleQuote),
      doubleQuote = EscapedCharCodec(quoting: Quoting.doubleQuote);

  group("String escape", () {
    test("quoting", () {
      expect(singleQuote.encode("123"), equals(r"'123'"));
      expect(doubleQuote.encode("false"), equals(r'"false"'));
      expect(singleQuote.decode(r"'456'"), equals("456"));
      expect(doubleQuote.decode(r'"true"'), equals("true"));
    });
    test("control character", () {
      expect(doubleQuote.encode("foo\nbar"), equals(r'foo\nbar'));
      expect(doubleQuote.encode("1\t2\r\n3"), equals(r'1\t2\r\n3'));
      expect(doubleQuote.decode(r'abc\n\tdef'), equals("abc\n\tdef"));
      expect(doubleQuote.decode(r'4\t\r5'), equals("4\t\r5"));
    });
  });
}
