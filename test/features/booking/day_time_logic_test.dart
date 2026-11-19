import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lavender/data/models/responses/doctor.dart';
import 'package:lavender/features/booking/day_time_logic.dart';

WorkTimeModel _day(String date, {int active = 1, int times = 1}) => WorkTimeModel(
      day: 'd',
      dayTranslated: 'D',
      date: '${date}T00:00:00.000000Z',
      isActive: active,
      times: [
        for (var i = 0; i < times; i++)
          TimeModel(time: '0$i:00', timeFormatted: '0$i:00'),
      ],
    );

void main() {
  setUpAll(() => initializeDateFormatting());

  final days = [
    _day('2025-03-08', active: 0),
    _day('2025-03-09'),
    _day('2025-03-10', times: 0),
    _day('2025-03-11'),
  ];

  group('initialDay', () {
    test('first element even when inactive', () {
      expect(initialDay(days), days.first);
    });
    test('null when empty', () => expect(initialDay(const []), isNull));
  });

  group('activeDates', () {
    test('only isActive == 1, date-only UTC', () {
      expect(activeDates(days), [
        DateTime.utc(2025, 3, 9),
        DateTime.utc(2025, 3, 10),
        DateTime.utc(2025, 3, 11),
      ]);
    });
    test('empty list', () => expect(activeDates(const []), isEmpty));
  });

  group('findDayForDate', () {
    test('finds an active day ignoring the time of day', () {
      expect(findDayForDate(days, DateTime(2025, 3, 9, 15, 30)), days[1]);
    });
    test('inactive day -> null', () {
      expect(findDayForDate(days, DateTime(2025, 3, 8)), isNull);
    });
    test('unknown date -> null', () {
      expect(findDayForDate(days, DateTime(2025, 4, 1)), isNull);
    });
  });

  test('dayHasTimes', () {
    expect(dayHasTimes(days[0]), isFalse); // inactive
    expect(dayHasTimes(days[1]), isTrue);
    expect(dayHasTimes(days[2]), isFalse); // no times
    expect(dayHasTimes(null), isFalse);
  });
}
