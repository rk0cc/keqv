import 'package:keqv/keqv.dart';

void main() {
  const String mock = '''foo = bar
number = 3
''';

  print(keqv.decode(mock));

  const Map<String, dynamic> dummy = {"baz": "alice", "none": null};

  print(keqv.encode(dummy));
}
