import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../data/models/responses/speciality.dart';
import '../../../shared/domain/repositories/home_repository.dart';
import '../../../shared/domain/repositories/specialities_repository.dart';
import '../../../shared/domain/entities/search_filter.dart';
import 'search_details_state.dart';

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
