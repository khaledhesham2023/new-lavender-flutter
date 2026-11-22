import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../core/enums/enums.dart';
import '../../../shared/domain/repositories/booking_repository.dart';
import 'bookings_state.dart';

class BookingsCubit extends Cubit<BookingsState> {
  BookingsCubit(this._repo) : super(const BookingsState());

  final BookingRepository _repo;

  /// Only the newest request may update the state (Android `collectLatest`).
  int _requestId = 0;

  /// Clears the list first (like Android), then loads the current selection.
  Future<void> load() async {
    final id = ++_requestId;
    emit(
      state.copyWith(
        items: const [],
        viewStatus: ViewStatus.loading,
        failure: () => null,
      ),
    );
    final result = await _repo.list(
      status: state.status.value,
      month: state.month,
      keyword: state.keyword,
      type: state.type,
    );
    if (isClosed || id != _requestId) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(items: data, viewStatus: ViewStatus.success));
      case ApiFailure():
        emit(
          state.copyWith(
            items: const [],
            viewStatus: ViewStatus.failure,
            failure: () => result,
          ),
        );
    }
  }

  /// Re-tapping the selected tab does nothing (Android `onTabReselected`).
  Future<void> selectTab(BookingStatus status) {
    if (status == state.status) return Future.value();
    emit(state.copyWith(status: status));
    return load();
  }

  /// A blank keyword means "no keyword".
  Future<void> setKeyword(String? keyword) {
    final trimmed = keyword?.trim();
    emit(
      state.copyWith(
        keyword: () => (trimmed == null || trimmed.isEmpty) ? null : trimmed,
      ),
    );
    return load();
  }

  Future<void> setMonth(String? month) {
    emit(state.copyWith(month: () => month));
    return load();
  }

  Future<void> setType(String? type) {
    emit(state.copyWith(type: () => type));
    return load();
  }

  /// Drops one item after a cancel / change succeeded (T27). Android then shows
  /// the empty view when the list becomes empty; the screen does the same.
  void removeAt(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items]..removeAt(index);
    emit(state.copyWith(items: items));
  }

  /// Refetches the current selection (after details / actions changed things).
  Future<void> reload() => load();
}
