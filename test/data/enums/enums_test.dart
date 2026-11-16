import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/data/enums/enums.dart';

void main() {
  test('fromValue maps the backend strings', () {
    expect(BookingStatus.fromValue('confirmed'), BookingStatus.confirmed);
    expect(BookingStatus.canceled.position, 4);
    expect(BookingStatus.pending.position, 0);
    expect(AppointmentType.fromValue('not_offer'), AppointmentType.notOffer);
    expect(AppointmentType.fromValue('default'), AppointmentType.defaultType);
    expect(OfferType.fromValue('valid'), OfferType.valid);
    expect(ReportType.fromValue('radiology'), ReportType.radiology);
    expect(SortByStatus.fromValue('low_to_high_rate'),
        SortByStatus.lowToHighRate);
    expect(GenderType.fromValue('female'), GenderType.female);
    expect(NotificationType.fromValue('user_offer'), NotificationType.userOffer);
  });

  test('fromValue returns null for unknown or null', () {
    expect(BookingStatus.fromValue('x'), isNull);
    expect(OfferType.fromValue(null), isNull);
  });

  test('values round trip', () {
    for (final e in BookingStatus.values) {
      expect(BookingStatus.fromValue(e.value), e);
    }
    for (final e in SortByStatus.values) {
      expect(SortByStatus.fromValue(e.value), e);
    }
  });
}
