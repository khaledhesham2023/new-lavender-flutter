import 'package:equatable/equatable.dart';

import '../../../../data/models/responses/notification.dart';

/// One page of the user's notifications.
///
/// `NotificationModel` stands in for a `Notification` entity until the shared
/// models get their own entities.
class NotificationsPage extends Equatable {
  const NotificationsPage({
    required this.items,
    required this.isLast,
    this.lastPage,
  });

  final List<NotificationModel> items;

  /// Android stops paging when a page comes back empty.
  final bool isLast;

  /// `meta.last_page` when the backend sends it.
  final int? lastPage;

  @override
  List<Object?> get props => [items, isLast, lastPage];
}
