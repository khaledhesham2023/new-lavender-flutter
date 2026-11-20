import 'package:intl/intl.dart';

// Ports of the Android date/time helpers (utils/extensions/ViewExtFunctions.kt).
// Names are kept so screen tasks map 1:1. Every function returns '' on a parse
// failure, like the Kotlin ones. Locale-dependent formats need
// `initializeDateFormatting()` to have run (main.dart).

final RegExp _isoDatePart = RegExp(r'^(\d{4})-(\d{2})-(\d{2})');
final RegExp _arabicDigits = RegExp('[٠-٩۰-۹]');

/// Replaces Arabic-Indic and Persian digits with 0-9.
String toArabicFreeDigits(String s) => s.replaceAllMapped(_arabicDigits, (m) {
      final c = m[0]!.codeUnitAt(0);
      return String.fromCharCode(0x30 + (c >= 0x06F0 ? c - 0x06F0 : c - 0x0660));
    });

DateTime? _parseOrNull(DateFormat f, String s) {
  try {
    return f.parseStrict(s);
  } catch (_) {
    return null;
  }
}

/// ISO zoned date -> `M/d` (e.g. `2025-03-07T10:00:00Z` -> `3/7`).
String formatDateToDayMonth(String iso) {
  final m = _isoDatePart.firstMatch(iso);
  if (m == null) return '';
  return '${int.parse(m[2]!)}/${int.parse(m[3]!)}';
}

final RegExp _hhmmPrefix = RegExp(r'^\s*(\d{1,2}:\d{2})');

/// Android parses with a lenient `SimpleDateFormat("HH:mm")`, which accepts
/// `09:15:00` (the API's `from`/`to`) and ignores what follows the minutes.
/// `parseStrict` would reject it, so keep only the leading `HH:mm`.
String _leadingHhmm(String s) => _hhmmPrefix.firstMatch(s)?[1] ?? s;

/// `HH:mm` (a trailing `:ss` is ignored, like Android) -> `hh:mm a`, AM/PM
/// localized by [lang], digits English.
/// (The name is inverted on purpose: it returns the 12-hour form.)
String convertTo24HourTime(String hhmm, String lang) {
  final d = _parseOrNull(DateFormat('HH:mm', 'en'), _leadingHhmm(hhmm));
  if (d == null) return '';
  return toArabicFreeDigits(DateFormat('hh:mm a', lang).format(d));
}

/// `HH:mm:ss` -> `hh:mm a`, English.
String convertTo24HourTime2(String hhmmss) {
  final d = _parseOrNull(DateFormat('HH:mm:ss', 'en'), hhmmss);
  if (d == null) return '';
  return DateFormat('hh:mm a', 'en').format(d);
}

/// `HH:mm` (English) -> `hh:mm a` with AM/PM localized by [lang].
/// Android leaves locale digits here; we always emit English digits (PLAN 4.6).
String reverseConvertTo24HourTime(String hhmm, String lang) {
  final d = _parseOrNull(DateFormat('HH:mm', 'en'), _leadingHhmm(hhmm));
  if (d == null) return '';
  return toArabicFreeDigits(DateFormat('hh:mm a', lang).format(d));
}

/// `HH:mm` -> `hh:mm a`, English (Android `reverseConvertTo24HourTimeOnly`).
String reverseConvertTo24HourTimeOnly(String hhmm) =>
    reverseConvertTo24HourTime(hhmm, 'en');

/// `hh:mm a` in [lang] -> `HH:mm` (Android `convertTo24HourTimeOnly`).
String convertTo24HourTimeOnly(String hhmmA, String lang) {
  final d = _parseOrNull(DateFormat('hh:mm a', lang), hhmmA);
  if (d == null) return '';
  return DateFormat('HH:mm', 'en').format(d);
}

/// `HH:mm` -> `hh:mm` English (Android `makeTimeFixedOnEnglish`).
String makeTimeFixedOnEnglish(String hhmm) {
  final d = _parseOrNull(DateFormat('HH:mm', 'en'), hhmm);
  if (d == null) return '';
  return DateFormat('hh:mm', 'en').format(d);
}

/// `yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'` (UTC) -> `yyyy-MM-dd`.
String convertIsoToDateOnly(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return '';
  return DateFormat('yyyy-MM-dd', 'en').format(d.toUtc());
}

/// `yyyy-M-dd` -> `yyyy-MM-dd'T'00:00:00.000000'Z'`.
String convertDateOnlyToIso(String yyyyMd) {
  final m = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(yyyyMd.trim());
  if (m == null) return '';
  final y = int.parse(m[1]!), mo = int.parse(m[2]!), d = int.parse(m[3]!);
  final dt = DateTime.utc(y, mo, d);
  if (dt.month != mo || dt.day != d) return '';
  return '${DateFormat('yyyy-MM-dd', 'en').format(dt)}T00:00:00.000000Z';
}

/// UTC ISO -> local `hh:mm a` (locale [lang]); returns [iso] unchanged on failure.
String convertUtcToHourMinute(String iso, String lang) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return DateFormat('hh:mm a', lang).format(d.toLocal());
}

/// `yyyy-MM-dd` -> `dd MMMM yyyy` in [lang], digits English.
String convertDateToReadableFormat(String yyyyMMdd, String lang) {
  final d = _parseOrNull(DateFormat('yyyy-MM-dd', 'en'), yyyyMMdd);
  if (d == null) return '';
  return toArabicFreeDigits(DateFormat('dd MMMM yyyy', lang).format(d));
}

/// UTC ISO -> `dd MMMM yyyy` in [lang] (Android `formatToLongDate`).
String formatToLongDate(String iso, String lang) {
  final d = DateTime.tryParse(iso);
  if (d == null) return '';
  return toArabicFreeDigits(DateFormat('dd MMMM yyyy', lang).format(d.toUtc()));
}

/// `yyyy-MM-dd` -> UTC midnight in epoch millis; 0 on failure.
int parseDateToUtcMillis(String yyyyMMdd) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(yyyyMMdd.trim());
  if (m == null) return 0;
  return DateTime.utc(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!))
      .millisecondsSinceEpoch;
}

/// Milliseconds -> `mm:ss` (minutes are not wrapped at 60, like Android).
String convertSecondsString(int millis) {
  final minutes = millis ~/ 60000;
  final seconds = millis ~/ 1000 - minutes * 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}
