import '../../core/enums/enums.dart';
import '../router/routes.dart';

/// Where a push notification opens. Port of
/// `MainActivity.handleNotificationNavigation` (the FCM `data` payload carries
/// `notify_type` and `notify_id`).
abstract final class NotificationTarget {
  static String fromData(Map<String, dynamic> data) {
    final id = int.tryParse('${data['notify_id'] ?? ''}') ?? 0;
    return switch (NotificationType.fromValue(
      data['notify_type']?.toString(),
    )) {
      NotificationType.appointment => Routes.appointmentDetailsOf(id),
      NotificationType.offer => Routes.offerDetailsOf(id),
      NotificationType.userOffer => Routes.myOfferDetailsOf(id),
      NotificationType.report => Routes.myReports,
      null => Routes.home,
    };
  }
}
