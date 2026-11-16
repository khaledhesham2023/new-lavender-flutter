T? _byValue<T>(List<T> values, String Function(T) key, String? value) {
  for (final v in values) {
    if (key(v) == value) return v;
  }
  return null;
}

enum BookingStatus {
  pending('pending', 0),
  confirmed('confirmed', 1),
  processing('processing', 2),
  completed('completed', 3),
  canceled('canceled', 4),
  rejected('rejected', 5);

  const BookingStatus(this.value, this.position);
  final String value;
  final int position;

  static BookingStatus? fromValue(String? v) =>
      _byValue(values, (e) => e.value, v);
}

enum AppointmentType {
  defaultType('default'),
  offer('offer'),
  notOffer('not_offer');

  const AppointmentType(this.value);
  final String value;

  static AppointmentType? fromValue(String? v) =>
      _byValue(values, (e) => e.value, v);
}

enum OfferType {
  valid('valid'),
  completed('completed');

  const OfferType(this.value);
  final String value;

  static OfferType? fromValue(String? v) => _byValue(values, (e) => e.value, v);
}

enum ReportType {
  radiology('radiology'),
  laboratory('laboratory');

  const ReportType(this.value);
  final String value;

  static ReportType? fromValue(String? v) =>
      _byValue(values, (e) => e.value, v);
}

enum SortByStatus {
  highToLowPrice('high_to_low_price'),
  lowToHighPrice('low_to_high_price'),
  highToLowRate('high_to_low_rate'),
  lowToHighRate('low_to_high_rate');

  const SortByStatus(this.value);
  final String value;

  static SortByStatus? fromValue(String? v) =>
      _byValue(values, (e) => e.value, v);
}

enum GenderType {
  male('male'),
  female('female');

  const GenderType(this.value);
  final String value;

  static GenderType? fromValue(String? v) =>
      _byValue(values, (e) => e.value, v);
}

enum NotificationType {
  appointment('appointment'),
  offer('offer'),
  report('report'),
  userOffer('user_offer');

  const NotificationType(this.value);
  final String value;

  static NotificationType? fromValue(String? v) =>
      _byValue(values, (e) => e.value, v);
}
