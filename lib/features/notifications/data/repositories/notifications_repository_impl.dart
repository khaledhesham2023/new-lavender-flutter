import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../data/json/json_utils.dart';
import '../../../../data/models/responses/base_response.dart';
import '../../../../data/models/responses/notification.dart';
import '../../../../data/repositories/repository_parsers.dart';
import '../../domain/entities/notifications_page.dart';
import '../../domain/repositories/notifications_repository.dart';

/// [NotificationsRepository] over the Lavender API.
class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<ApiResult<NotificationsPage>> getPage(int page) => _api.call(
    (s) => s.notifications(page),
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

  @override
  Future<ApiResult<void>> delete(String id) =>
      _api.call((s) => s.deleteNotification(id), parse: parseVoid);

  @override
  Future<ApiResult<void>> markRead(String id) =>
      _api.call((s) => s.readNotification(id), parse: parseVoid);

  @override
  Future<ApiResult<void>> readAll() =>
      _api.call((s) => s.readAllNotifications(), parse: parseVoid);

  /// Laravel method spoofing: POST with `_method=PUT`.
  @override
  Future<ApiResult<bool>> toggleAllow() => _api.call(
    (s) => s.allowNotifications('PUT'),
    parse: (j) => asBool(asMap(asMap(j)?['data'])?['allow_notification']),
  );
}
