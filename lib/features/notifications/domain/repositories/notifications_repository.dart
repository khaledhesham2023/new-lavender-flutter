import '../../../../core/network/api_result.dart';
import '../entities/notifications_page.dart';

/// What the notifications feature needs from the outside world. The
/// presentation layer depends on this contract only;
/// `NotificationsRepositoryImpl` (data layer) implements it.
abstract interface class NotificationsRepository {
  /// Page [page] (first page is 1) of the user's notifications.
  Future<ApiResult<NotificationsPage>> getPage(int page);

  Future<ApiResult<void>> delete(String id);

  Future<ApiResult<void>> markRead(String id);

  /// Kept for completeness; unused by the UI.
  Future<ApiResult<void>> readAll();

  /// Flips "allow notifications" on the server; returns the new value.
  Future<ApiResult<bool>> toggleAllow();
}
