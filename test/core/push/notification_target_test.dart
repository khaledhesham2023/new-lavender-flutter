import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/push/notification_target.dart';
import 'package:lavender/router/routes.dart';

void main() {
  group('NotificationTarget.fromData', () {
    test('appointment opens the appointment details', () {
      expect(
        NotificationTarget.fromData({
          'notify_type': 'appointment',
          'notify_id': '42',
        }),
        Routes.appointmentDetailsOf(42),
      );
    });

    test('offer opens the offer details', () {
      expect(
        NotificationTarget.fromData({'notify_type': 'offer', 'notify_id': '7'}),
        Routes.offerDetailsOf(7),
      );
    });

    test('user_offer opens my offer details', () {
      expect(
        NotificationTarget.fromData({
          'notify_type': 'user_offer',
          'notify_id': '9',
        }),
        Routes.myOfferDetailsOf(9),
      );
    });

    test('report opens my reports, whatever the id', () {
      expect(
        NotificationTarget.fromData({'notify_type': 'report'}),
        Routes.myReports,
      );
      expect(
        NotificationTarget.fromData({
          'notify_type': 'report',
          'notify_id': '5',
        }),
        Routes.myReports,
      );
    });

    test('a missing or non-numeric id becomes 0', () {
      expect(
        NotificationTarget.fromData({'notify_type': 'appointment'}),
        Routes.appointmentDetailsOf(0),
      );
      expect(
        NotificationTarget.fromData({
          'notify_type': 'offer',
          'notify_id': 'abc',
        }),
        Routes.offerDetailsOf(0),
      );
    });

    test('a numeric (non-string) id is accepted', () {
      expect(
        NotificationTarget.fromData({'notify_type': 'offer', 'notify_id': 3}),
        Routes.offerDetailsOf(3),
      );
    });

    test('unknown, empty or missing type opens Home', () {
      expect(
        NotificationTarget.fromData({'notify_type': 'weird', 'notify_id': '1'}),
        Routes.home,
      );
      expect(NotificationTarget.fromData({'notify_type': ''}), Routes.home);
      expect(NotificationTarget.fromData(const {}), Routes.home);
    });
  });
}
