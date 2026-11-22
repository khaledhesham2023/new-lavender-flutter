import 'package:equatable/equatable.dart';

import '../../../core/network/api_result.dart';
import '../../../data/models/responses/doctor.dart';
import '../../../data/models/responses/home.dart';

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
