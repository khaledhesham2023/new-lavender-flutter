import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../core/storage/app_prefs.dart';
import '../../data/repositories/notifications_repository.dart';

class NotificationsState extends Equatable {
  /// The "allow notifications" switch (initialized from the stored value).
  final bool allowed;

  /// A toggle request is in flight.
  final bool toggling;

  /// One-shot: the toggle failed and the switch was put back (the screen
  /// toasts it, then calls [NotificationsCubit.consumeToggleFailure]).
  final ApiFailure<dynamic>? toggleFailure;

  const NotificationsState({
    required this.allowed,
    this.toggling = false,
    this.toggleFailure,
  });

  @override
  List<Object?> get props => [allowed, toggling, toggleFailure];
}

/// Port of the non-paging half of `NotificationsViewModel`: the allow switch and
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

  Future<ApiResult<void>> markRead(String id) => _repository.markRead(id);

  Future<ApiResult<void>> delete(String id) => _repository.delete(id);
}
