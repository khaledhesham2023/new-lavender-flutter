part of 'favorites_cubit.dart';

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
