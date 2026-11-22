import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/storage/app_prefs.dart';
import '../../domain/entities/notifications_page.dart';
import '../../domain/repositories/notifications_repository.dart';

part 'notifications_state.dart';

/// Port of `NotificationsViewModel`: the allow switch, the page requests and
/// the read / delete requests. The list itself is a `PagingController` owned by
/// the screen.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository, this._prefs)
    : super(NotificationsState(allowed: _prefs.allowNotifications));

  final NotificationsRepository _repository;
  final AppPrefs _prefs;

  /// Flips the switch at once (Android does); a failure flips it back.
  Future<void> toggleAllow() async {
    if (state.toggling) return;
    final previous = state.allowed;
    emit(NotificationsState(allowed: !previous, toggling: true));
    final result = await _repository.toggleAllow();
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        await _prefs.setAllowNotifications(data);
        if (isClosed) return;
        emit(NotificationsState(allowed: data));
      case ApiFailure():
        emit(NotificationsState(allowed: previous, toggleFailure: result));
    }
  }

  void consumeToggleFailure() =>
      emit(NotificationsState(allowed: state.allowed));

  /// Page [page] (first page is 1) for the screen's `PagingController`.
  Future<ApiResult<NotificationsPage>> getPage(int page) =>
      _repository.getPage(page);

  Future<ApiResult<void>> markRead(String id) => _repository.markRead(id);

  Future<ApiResult<void>> delete(String id) => _repository.delete(id);
}
