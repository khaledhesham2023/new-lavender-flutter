import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/data/models/json_utils.dart';

void main() {
  test('asInt', () {
    expect(asInt(5), 5);
    expect(asInt('7'), 7);
    expect(asInt('150.00'), 150);
    expect(asInt(3.9), 3);
    expect(asInt(null), isNull);
    expect(asInt('abc'), isNull);
    expect(asInt([1]), isNull);
  });

  test('asDouble', () {
    expect(asDouble(4), 4.0);
    expect(asDouble('150.50'), 150.5);
    expect(asDouble(null), isNull);
    expect(asDouble('x'), isNull);
  });

  test('asString', () {
    expect(asString('a'), 'a');
    expect(asString(12), '12');
    expect(asString(null), isNull);
    expect(asString({'a': 1}), isNull);
  });

  test('asBool', () {
    expect(asBool(true), isTrue);
    expect(asBool(1), isTrue);
    expect(asBool(0), isFalse);
    expect(asBool('1'), isTrue);
    expect(asBool('0'), isFalse);
    expect(asBool('true'), isTrue);
    expect(asBool(null), isFalse);
    expect(asBool(null, fallback: true), isTrue);
    expect(asBoolOrNull(null), isNull);
    expect(asBoolOrNull(1), isTrue);
  });

  test('asList skips non-objects and tolerates null', () {
    expect(asList(null, (m) => m['a']), isEmpty);
    expect(asList('x', (m) => m['a']), isEmpty);
    expect(
      asList([
        {'a': 1},
        5,
        {'a': 2},
      ], (m) => m['a']),
      [1, 2],
    );
    expect(asStringList([1, 'b', null]), ['1', 'b']);
  });

  test('withoutNulls', () {
    expect(withoutNulls({'a': 1, 'b': null}), {'a': 1});
  });
}
