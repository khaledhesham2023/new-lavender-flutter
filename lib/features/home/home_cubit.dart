import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../core/storage/app_prefs.dart';
import '../../data/models/responses/doctor.dart';
import '../../data/models/responses/home.dart';
import '../../data/models/responses/speciality.dart';
import '../../shared/domain/repositories/general_repository.dart';
import '../../shared/domain/repositories/home_repository.dart';

/// Home grid: the "Medical offers" tile first, then the specialities. With 8 or
/// more specialities only the first 7 are kept; the tile at index 7 is drawn as
/// "More" by the widget (port of `SpecialitiesAdapter.submitList`, `inHome`).
List<SpecialityModel> buildHomeSpecialities(
  List<SpecialityModel> specialities,
  String medicalOffersLabel,
) {
  return [
    SpecialityModel(id: 0, name: medicalOffersLabel),
    if (specialities.length >= 8) ...specialities.take(7) else ...specialities,
  ];
}

class HomeState extends Equatable {
  final ViewStatus status;
  final HomeData? data;
  final List<DoctorModel> doctors;

  /// Failure of `getHome`; the screen picks the view from its type.
  final ApiFailure<dynamic>? failure;

  /// One-shot: a favorite toggle failed and was reverted (the screen toasts it,
  /// then calls [HomeCubit.consumeFavoriteFailure]).
  final ApiFailure<dynamic>? favoriteFailure;

  const HomeState({
    this.status = ViewStatus.initial,
    this.data,
    this.doctors = const [],
    this.failure,
    this.favoriteFailure,
  });

  HomeState copyWith({
    ViewStatus? status,
    HomeData? data,
    List<DoctorModel>? doctors,
    ApiFailure<dynamic>? failure,
    ApiFailure<dynamic>? favoriteFailure,
    bool clearFailure = false,
    bool clearFavoriteFailure = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      data: data ?? this.data,
      doctors: doctors ?? this.doctors,
      failure: clearFailure ? null : (failure ?? this.failure),
      favoriteFailure: clearFavoriteFailure
          ? null
          : (favoriteFailure ?? this.favoriteFailure),
    );
  }

  @override
  List<Object?> get props => [status, data, doctors, failure, favoriteFailure];
}

/// Port of `HomeViewModel`.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._home, this._general, this._prefs) : super(const HomeState());

  final HomeRepository _home;
  final GeneralRepository _general;
  final AppPrefs _prefs;

  /// Loads home and, in parallel, the app settings (saved to prefs; a settings
  /// failure is ignored, as on Android).
  Future<void> load() async {
    emit(const HomeState(status: ViewStatus.loading));
    await Future.wait<void>([_loadHome(), _loadSettings()]);
  }

  /// Refetches home without the loading state (after coming back from a
  /// details screen, as Android does in `onResume`). Failures keep what is
  /// shown.
  Future<void> refresh() async {
    final result = await _home.getHome();
    if (isClosed || result is! ApiSuccess<HomeData>) return;
    emit(
      HomeState(
        status: ViewStatus.success,
        data: result.data,
        doctors: result.data.doctors,
      ),
    );
  }

  Future<void> _loadHome() async {
    final result = await _home.getHome();
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(
          HomeState(
            status: ViewStatus.success,
            data: data,
            doctors: data.doctors,
          ),
        );
      case ApiFailure():
        emit(HomeState(status: ViewStatus.failure, failure: result));
    }
  }

  Future<void> _loadSettings() async {
    final result = await _general.getSettings();
    if (result case ApiSuccess(:final data)) {
      await _prefs.setAllowNotifications(data.allowNotification ?? false);
      await _prefs.setWhatsAppNumber(data.whatsAppNumber ?? '');
    }
  }

  /// Flips the heart immediately, then calls the API; on failure flips it back
  /// and exposes [HomeState.favoriteFailure].
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
