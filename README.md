# Simplest `key=value` coded implementation in Dart

It provides conversion between key-value pair statements:

```text
foo = bar
number = 23
unexisted = 
correct = true
falseString = "false"
```

to Dart's `Map` object:

```dart
const result = {
    "foo": "bar",
    "number": 23
    "unexisted": null,
    "correct": true,
    "falseString": "false"
};
```

## Supported value type

* `bool`
* `num`
* `Null`
* `String`

## Format

### Key's naming scheme

Name of keys must contains an alphanumeric string along with space, dollar sign and underscore characters only.

### Force value storing as `String`

Uses quote symbol to prevent values are decoded to `num` or `bool`.

## License

BSD-3
