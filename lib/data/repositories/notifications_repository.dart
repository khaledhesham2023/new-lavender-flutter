import 'package:equatable/equatable.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../../core/network/endpoints.dart';
import '../json/json_utils.dart';
import '../models/responses/base_response.dart';
import '../models/responses/notification.dart';
import 'repository_parsers.dart';

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

class NotificationsRepository {
  NotificationsRepository(this._api);

  final ApiClient _api;

  Future<ApiResult<NotificationsPage>> getPage(int page) => _api.get(
    Endpoints.notifications,
    query: {'page': page},
    parse: (j) {
      final body = asMap(j);
      final items = asList(body?['data'], NotificationModel.fromJson);
      final meta = asObject(body?['meta'], PaginationMeta.fromJson);
      return NotificationsPage(
        items: items,
        isLast: items.isEmpty,
        lastPage: meta?.lastPage,
      );
    },
  );

  Future<ApiResult<void>> delete(String id) =>
      _api.delete(Endpoints.notification(id), parse: parseVoid);

  Future<ApiResult<void>> markRead(String id) =>
      _api.get(Endpoints.readNotification(id), parse: parseVoid);

  /// Kept for completeness; unused by the UI.
  Future<ApiResult<void>> readAll() =>
      _api.get(Endpoints.readAllNotifications, parse: parseVoid);

  /// Laravel method spoofing: POST with `_method=PUT`.
  Future<ApiResult<bool>> toggleAllow() => _api.post(
    Endpoints.allowNotifications,
    query: {'_method': 'PUT'},
    parse: (j) => asBool(asMap(asMap(j)?['data'])?['allow_notification']),
  );
}
