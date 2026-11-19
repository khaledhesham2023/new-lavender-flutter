import '../../core/utils/date_utils.dart';
import '../../data/models/responses/doctor.dart';

// Port of the selection rules in `BookingAppointmentsFragment` / `BookingDaysAdapter`.

/// The day preselected on new data: always the first one, even if inactive
/// (Android `submitList` selects index 0). Null when [days] is empty.
WorkTimeModel? initialDay(List<WorkTimeModel> days) =>
    days.isEmpty ? null : days.first;

/// Dates (date only, UTC midnight) of the days with `isActive == 1`.
/// Compared as date values, never as instants.
List<DateTime> activeDates(List<WorkTimeModel> days) {
  final result = <DateTime>[];
  for (final day in days) {
    if (day.isActive != 1) continue;
    final date = _dateOnly(day.date);
    if (date != null) result.add(date);
  }
  return result;
}

/// The day whose date equals [date]; returned only when it is not inactive
/// (`isActive != 0`), like `BookingDaysAdapter.getDateIfExists`.
WorkTimeModel? findDayForDate(List<WorkTimeModel> days, DateTime date) {
  final target = DateTime.utc(date.year, date.month, date.day);
  for (final day in days) {
    if (_dateOnly(day.date) == target) {
      return day.isActive != 0 ? day : null;
    }
  }
  return null;
}

/// Whether [day] has bookable times to show (active and non-empty).
bool dayHasTimes(WorkTimeModel? day) =>
    day != null && day.isActive != 0 && day.times.isNotEmpty;

DateTime? _dateOnly(String? iso) {
  if (iso == null) return null;
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$')
      .firstMatch(convertIsoToDateOnly(iso));
  if (m == null) return null;
  return DateTime.utc(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
}
