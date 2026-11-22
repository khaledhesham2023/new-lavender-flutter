import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show ValueGetter;

import '../../../core/network/api_result.dart';
import '../../../core/enums/enums.dart';
import '../../../data/models/responses/appointment.dart';

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
