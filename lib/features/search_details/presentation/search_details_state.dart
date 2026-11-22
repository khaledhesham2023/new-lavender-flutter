import 'package:equatable/equatable.dart';

import '../../../core/network/api_result.dart';
import '../../../data/models/responses/doctor.dart';
import '../../../shared/domain/entities/search_filter.dart';

class SearchDetailsState extends Equatable {
  final ViewStatus status;
  final List<DoctorModel> doctors;

  /// Number shown in "All doctors (n)": the list length, as on Android.
  final int count;
  final SearchFilter filter;

  /// Trimmed doctor-name search; null when blank.
  final String? name;

  /// Failure of the list request; the screen picks the view from its type.
  final ApiFailure<dynamic>? failure;

  /// One-shot: a favorite toggle failed and was reverted (the screen toasts it,
  /// then calls [SearchDetailsCubit.consumeFavoriteFailure]).
  final ApiFailure<dynamic>? favoriteFailure;

  const SearchDetailsState({
    this.status = ViewStatus.initial,
    this.doctors = const [],
    this.count = 0,
    this.filter = const SearchFilter(),
    this.name,
    this.failure,
    this.favoriteFailure,
  });

  SearchDetailsState copyWith({
    ViewStatus? status,
    List<DoctorModel>? doctors,
    int? count,
    SearchFilter? filter,
    String? name,
    bool clearName = false,
    ApiFailure<dynamic>? failure,
    bool clearFailure = false,
    ApiFailure<dynamic>? favoriteFailure,
    bool clearFavoriteFailure = false,
  }) {
    return SearchDetailsState(
      status: status ?? this.status,
      doctors: doctors ?? this.doctors,
      count: count ?? this.count,
      filter: filter ?? this.filter,
      name: clearName ? null : (name ?? this.name),
      failure: clearFailure ? null : (failure ?? this.failure),
      favoriteFailure: clearFavoriteFailure
          ? null
          : (favoriteFailure ?? this.favoriteFailure),
    );
  }

  @override
  List<Object?> get props => [
    status,
    doctors,
    count,
    filter,
    name,
    failure,
    favoriteFailure,
  ];
}
