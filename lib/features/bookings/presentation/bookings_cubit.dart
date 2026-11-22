import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show ValueGetter;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../core/enums/enums.dart';
import '../../../data/models/responses/appointment.dart';
import '../../../shared/domain/repositories/booking_repository.dart';

class BookingsState extends Equatable {
  final BookingStatus status;

  /// `"3"`, `"6"`, `"12"` or null (no date filter).
  final String? month;

  /// `default` / `offer` / `not_offer` or null.
  final String? type;
  final String? keyword;
  final List<AppointmentData> items;
  final ViewStatus viewStatus;
  final ApiFailure<dynamic>? failure;

  const BookingsState({
    this.status = BookingStatus.pending,
    this.month,
    this.type,
    this.keyword,
    this.items = const [],
    this.viewStatus = ViewStatus.initial,
    this.failure,
  });

  /// Red dot on the filter-by-date icon (`ivCircleRed`).
  bool get hasDateFilter => month != null;

  /// Red dot on the filter-by-type icon (`ivCircleRedForType`): `default`
  /// means "all", so it does not count.
  bool get hasTypeFilter =>
      type != null && type != AppointmentType.defaultType.value;

  BookingsState copyWith({
    BookingStatus? status,
    ValueGetter<String?>? month,
    ValueGetter<String?>? type,
    ValueGetter<String?>? keyword,
    List<AppointmentData>? items,
    ViewStatus? viewStatus,
    ValueGetter<ApiFailure<dynamic>?>? failure,
  }) {
    return BookingsState(
      status: status ?? this.status,
      month: month != null ? month() : this.month,
      type: type != null ? type() : this.type,
      keyword: keyword != null ? keyword() : this.keyword,
      items: items ?? this.items,
      viewStatus: viewStatus ?? this.viewStatus,
      failure: failure != null ? failure() : this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    month,
    type,
    keyword,
    items,
    viewStatus,
    failure,
  ];
}

/// Port of `BookingsFragment` state + `BookingSearchViewModel`
/// (`handleGetBookingByStatus`): one status tab, an optional keyword, date and
/// type filter, and the matching appointments.
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
