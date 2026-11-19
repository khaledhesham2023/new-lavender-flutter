import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../data/models/responses/doctor.dart';
import '../../data/models/responses/speciality.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/repositories/specialities_repository.dart';
import 'search_filter.dart';

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

/// Port of `SearchDetailsViewModel` + the request logic of
/// `SearchDetailsFragment`: doctors of one speciality with name search, sort,
/// filter and optimistic favorites.
class SearchDetailsCubit extends Cubit<SearchDetailsState> {
  SearchDetailsCubit(this._specialities, this._home, this.speciality)
    : super(const SearchDetailsState());

  final SpecialitiesRepository _specialities;
  final HomeRepository _home;
  final SpecialityModel speciality;

  int _requestId = 0;

  /// Loads the list with the current name, sort and filter. Only the latest
  /// request may update the state (a slow older answer is dropped).
  Future<void> load() async {
    final id = ++_requestId;
    final filter = state.filter;
    emit(state.copyWith(status: ViewStatus.loading, clearFailure: true));
    final result = await _specialities.getDoctors(
      speciality.id,
      sortBy: filter.sortBy,
      subSpecialtyIds: [
        for (final s in filter.subSpecialties)
          if (s.id != null) s.id!,
      ],
      gender: filter.gender,
      maxPrice: filter.maxPrice,
      minPrice: filter.minPrice,
      name: state.name,
    );
    if (isClosed || id != _requestId) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(
          state.copyWith(
            status: ViewStatus.success,
            doctors: data.doctors,
            count: data.doctors.length,
          ),
        );
      case ApiFailure():
        emit(state.copyWith(status: ViewStatus.failure, failure: result));
    }
  }

  /// Blank text means "no name filter".
  Future<void> setName(String text) {
    final trimmed = text.trim();
    emit(
      trimmed.isEmpty
          ? state.copyWith(clearName: true)
          : state.copyWith(name: trimmed),
    );
    return load();
  }

  Future<void> setSort(String? sortBy) {
    emit(state.copyWith(filter: state.filter.copyWith(sortBy: () => sortBy)));
    return load();
  }

  Future<void> applyFilter(SearchFilter filter) {
    emit(state.copyWith(filter: filter));
    return load();
  }

  /// Flips the heart immediately, then calls the API; on failure flips it back
  /// and exposes [SearchDetailsState.favoriteFailure].
  Future<void> toggleFavorite(int index) async {
    if (index < 0 || index >= state.doctors.length) return;
    final doctor = state.doctors[index];
    final id = doctor.id;
    if (id == null) return;

    _setFav(id, !doctor.isFav);
    final result = await _home.toggleFavorite(id);
    if (isClosed) return;
    if (result case ApiFailure()) {
      _setFav(id, doctor.isFav);
      emit(state.copyWith(favoriteFailure: result));
    }
  }

  void _setFav(int id, bool value) {
    emit(
      state.copyWith(
        doctors: [
          for (final d in state.doctors)
            if (d.id == id) d.copyWith(isFav: value) else d,
        ],
      ),
    );
  }

  void consumeFavoriteFailure() =>
      emit(state.copyWith(clearFavoriteFailure: true));
}
