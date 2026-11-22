import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/features/my_offers/presentation/ordinal.dart';

void main() {
  group('numberToOrdinalWord', () {
    test('English 1..10', () {
      const expected = [
        'First',
        'Second',
        'Third',
        'Fourth',
        'Fifth',
        'Sixth',
        'Seventh',
        'Eighth',
        'Ninth',
        'Tenth',
      ];
      for (var i = 1; i <= 10; i++) {
        expect(numberToOrdinalWord(i, 'en'), expected[i - 1]);
      }
    });

    test('Arabic 1..10', () {
      const expected = [
        'الأولى',
        'الثانية',
        'الثالثة',
        'الرابعة',
        'الخامسة',
        'السادسة',
        'السابعة',
        'الثامنة',
        'التاسعة',
        'العاشرة',
      ];
      for (var i = 1; i <= 10; i++) {
        expect(numberToOrdinalWord(i, 'ar'), expected[i - 1]);
      }
    });

    test('English compound numbers join the tens and the lowercase unit', () {
      expect(numberToOrdinalWord(21, 'en'), 'Twentyfirst');
      expect(numberToOrdinalWord(35, 'en'), 'Thirtyfifth');
      expect(numberToOrdinalWord(20, 'en'), 'Twentieth');
    });

    test('Arabic compound numbers put the unit first', () {
      expect(numberToOrdinalWord(21, 'ar'), 'الحادية و عشرون');
      expect(numberToOrdinalWord(32, 'ar'), 'الثانية و ثلاثون');
      expect(numberToOrdinalWord(11, 'ar'), 'الحادية عشرة');
    });

    test('numbers outside the tables fall back', () {
      expect(numberToOrdinalWord(100, 'en'), '100th');
      expect(numberToOrdinalWord(100, 'ar'), 'الرقم 100');
      expect(numberToOrdinalWord(0, 'en'), '0th');
      expect(numberToOrdinalWord(0, 'ar'), 'الرقم 0');
    });

    test('an unknown language gives the plain number', () {
      expect(numberToOrdinalWord(3, 'fr'), '3');
    });
  });
}
