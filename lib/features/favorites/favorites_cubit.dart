import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../data/models/responses/doctor.dart';
import '../../data/repositories/favorites_repository.dart';

class FavoritesState extends Equatable {
  final ViewStatus status;
  final List<DoctorModel> doctors;

  /// Search keyword in effect (`null` = none).
  final String? keyword;
  final ApiFailure<dynamic>? failure;

  /// One-shot: an un-favorite failed and was reverted (the screen toasts it,
  /// then calls [FavoritesCubit.consumeToggleFailure]).
  final ApiFailure<dynamic>? toggleFailure;

  const FavoritesState({
    this.status = ViewStatus.initial,
    this.doctors = const [],
    this.keyword,
    this.failure,
    this.toggleFailure,
  });

  FavoritesState copyWith({
    List<DoctorModel>? doctors,
    ApiFailure<dynamic>? toggleFailure,
    bool clearToggleFailure = false,
  }) {
    return FavoritesState(
      status: status,
      doctors: doctors ?? this.doctors,
      keyword: keyword,
      failure: failure,
      toggleFailure: clearToggleFailure
          ? null
          : (toggleFailure ?? this.toggleFailure),
    );
  }

  @override
  List<Object?> get props => [status, doctors, keyword, failure, toggleFailure];
}

/// Port of `FavoritesViewModel`: the favorite doctors, filtered by name.
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._repository) : super(const FavoritesState());

  final FavoritesRepository _repository;

  /// Only the newest request may update the state.
  int _requestId = 0;

  /// Loads with the current keyword.
  Future<void> load() => _fetch(state.keyword);

  /// Blank text means "no keyword".
  Future<void> setKeyword(String text) {
    final trimmed = text.trim();
    return _fetch(trimmed.isEmpty ? null : trimmed);
  }

  Future<void> _fetch(String? keyword) async {
    final request = ++_requestId;
    emit(
      FavoritesState(
        status: ViewStatus.loading,
        keyword: keyword,
        // Keep the list so a refresh does not flash.
        doctors: state.doctors,
      ),
    );
    final result = await _repository.getFavorites(name: keyword);
    if (isClosed || request != _requestId) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(
          FavoritesState(
            status: ViewStatus.success,
            doctors: data,
            keyword: keyword,
          ),
        );
      case ApiFailure():
        emit(
          FavoritesState(
            status: ViewStatus.failure,
            keyword: keyword,
            failure: result,
          ),
        );
    }
  }

  /// Flips the heart at once (Android does), then removes the row when the API
  /// succeeds; on failure flips it back and exposes
  /// [FavoritesState.toggleFailure].
  Future<void> unfavorite(int index) async {
    if (index < 0 || index >= state.doctors.length) return;
    final doctor = state.doctors[index];
    final id = doctor.id;
    if (id == null) return;

    _setFav(id, !doctor.isFav);
    final result = await _repository.toggleFavorite(id);
    if (isClosed) return;
    switch (result) {
      case ApiSuccess():
        emit(
          state.copyWith(
            doctors: [
              for (final d in state.doctors)
                if (d.id != id) d,
            ],
          ),
        );
      case ApiFailure():
        _setFav(id, doctor.isFav);
        emit(state.copyWith(toggleFailure: result));
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

  void consumeToggleFailure() => emit(state.copyWith(clearToggleFailure: true));
}
