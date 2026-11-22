import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lavender/core/utils/date_utils.dart';

void main() {
  setUpAll(() => initializeDateFormatting());

  test('toArabicFreeDigits', () {
    expect(toArabicFreeDigits('١٢:٣٤ ۵'), '12:34 5');
    expect(toArabicFreeDigits('abc 12'), 'abc 12');
  });

  test('formatDateToDayMonth', () {
    expect(formatDateToDayMonth('2025-03-07T10:00:00Z'), '3/7');
    expect(formatDateToDayMonth('2025-12-25T23:30:00+03:00'), '12/25');
    expect(formatDateToDayMonth('nope'), '');
  });

  test('convertTo24HourTime (12-hour result, English digits)', () {
    expect(convertTo24HourTime('14:30', 'en'), '02:30 PM');
    expect(convertTo24HourTime('09:05', 'en'), '09:05 AM');
    final ar = convertTo24HourTime('14:30', 'ar');
    expect(ar, startsWith('02:30'));
    expect(ar, isNot(contains('PM')));
    expect(RegExp('[٠-٩]').hasMatch(ar), isFalse);
    expect(convertTo24HourTime('bad', 'en'), '');
  });

  test('convertTo24HourTime ignores seconds like Android (HH:mm:ss from API)',
      () {
    expect(convertTo24HourTime('09:15:00', 'en'), '09:15 AM');
    expect(convertTo24HourTime('18:00:00', 'en'), '06:00 PM');
    expect(reverseConvertTo24HourTime('14:30:00', 'en'), '02:30 PM');
  });

  test('convertTo24HourTime2 / reverse / makeTimeFixedOnEnglish', () {
    expect(convertTo24HourTime2('18:45:10'), '06:45 PM');
    expect(reverseConvertTo24HourTime('00:15', 'en'), '12:15 AM');
    expect(reverseConvertTo24HourTime('13:00', 'ar'), startsWith('01:00'));
    expect(reverseConvertTo24HourTimeOnly('07:00'), '07:00 AM');
    expect(makeTimeFixedOnEnglish('15:20'), '03:20');
    expect(convertTo24HourTimeOnly('03:20 PM', 'en'), '15:20');
  });

  test('convertIsoToDateOnly / convertDateOnlyToIso', () {
    expect(convertIsoToDateOnly('2025-03-07T10:00:00.000000Z'), '2025-03-07');
    expect(convertIsoToDateOnly('garbage'), '');
    expect(convertDateOnlyToIso('2025-3-07'), '2025-03-07T00:00:00.000000Z');
    expect(convertDateOnlyToIso('2025-03-07'), '2025-03-07T00:00:00.000000Z');
    expect(convertDateOnlyToIso('2025-02-31'), '');
  });

  test('convertDateToReadableFormat', () {
    expect(convertDateToReadableFormat('2025-03-07', 'en'), '07 March 2025');
    final ar = convertDateToReadableFormat('2025-03-07', 'ar');
    expect(ar, contains('07'));
    expect(ar, contains('2025'));
    expect(RegExp('[٠-٩]').hasMatch(ar), isFalse);
    expect(convertDateToReadableFormat('x', 'en'), '');
  });

  test('parseDateToUtcMillis', () {
    expect(parseDateToUtcMillis('1970-01-02'), 86400000);
    expect(parseDateToUtcMillis('bad'), 0);
  });

  test('convertSecondsString', () {
    expect(convertSecondsString(0), '00:00');
    expect(convertSecondsString(65000), '01:05');
    expect(convertSecondsString(599000), '09:59');
    expect(convertSecondsString(3600000), '60:00');
  });

  test('formatToLongDate', () {
    expect(formatToLongDate('2025-03-07T10:00:00.000000Z', 'en'), '07 March 2025');
  });

  // Android formats these in the device zone, not UTC (booking was saved one
  // day early on Flutter, PARITY.md). Expected values come from the test
  // machine's own zone so the test passes anywhere.
  test('ISO dates are converted to the local day, like Android', () {
    const iso = '2026-11-27T22:00:00.000000Z';
    final local = DateTime.utc(2026, 11, 27, 22).toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    expect(
      convertIsoToDateOnly(iso),
      '${local.year}-${two(local.month)}-${two(local.day)}',
    );
    expect(
      formatToLongDate(iso, 'en'),
      '${two(local.day)} November ${local.year}',
    );
    // In Egypt (UTC+2) that is the 28th: the day the server means.
    if (local.timeZoneOffset == const Duration(hours: 2)) {
      expect(convertIsoToDateOnly(iso), '2026-11-28');
    }
  });
}
