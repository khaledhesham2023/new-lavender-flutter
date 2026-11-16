import 'package:flutter_test/flutter_test.dart';

import '../../tool/strings2arb.dart';

void main() {
  group('toCamelCase', () {
    test('snake_case to lowerCamelCase', () {
      expect(toCamelCase('good_morning'), 'goodMorning');
      expect(toCamelCase('doctorM'), 'doctorM');
    });
    test('reserved word gets Text suffix', () {
      expect(toCamelCase('class'), 'classText');
      expect(toCamelCase('default'), 'defaultText');
    });
    test('leading digit gets a valid name', () {
      expect(toCamelCase('_1'), 'text1');
    });
  });

  group('convertPlaceholders', () {
    test('single %s', () {
      final r = convertPlaceholders('Good morning%s');
      expect(r.text, 'Good morning{p1}');
      expect(r.placeholders, ['p1']);
    });
    test('%1s/%2s are sequential args', () {
      final r = convertPlaceholders('(%1s/%2s) session');
      expect(r.text, '({p1}/{p2}) session');
      expect(r.placeholders, ['p1', 'p2']);
    });
    test('%% becomes %', () {
      final r = convertPlaceholders('%s%%');
      expect(r.text, '{p1}%');
      expect(r.placeholders, ['p1']);
    });
  });

  group('parseStringsXml', () {
    const xml = r'''
<resources>
  <string name="doctor">doctor\'s</string>
  <string name="cdata"><![CDATA[ Simple steps >> ]]></string>
  <string name="skip" translatable="false">x</string>
  <string-array name="arr"><item>a</item></string-array>
</resources>''';
    test('unescapes, keeps CDATA, skips non-translatable and arrays', () {
      final m = parseStringsXml(xml);
      expect(m['doctor'], "doctor's");
      expect(m['cdata'], 'Simple steps >>');
      expect(m.containsKey('skip'), isFalse);
      expect(m.length, 2);
    });
  });
}
