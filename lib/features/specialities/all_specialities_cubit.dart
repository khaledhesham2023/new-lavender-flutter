import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../data/models/responses/speciality.dart';
import '../../data/repositories/specialities_repository.dart';

/// "All specialities" list: the "Medical offers" tile (id 0) first, then every
/// speciality, with no "More" tile (port of `SpecialitiesAdapter.submitList`,
/// `inHome = false`).
List<SpecialityModel> buildAllSpecialities(
  List<SpecialityModel> specialities,
  String medicalOffersLabel,
) {
  return [SpecialityModel(id: 0, name: medicalOffersLabel), ...specialities];
}

class AllSpecialitiesState extends Equatable {
  final ViewStatus status;
  final List<SpecialityModel> specialities;

  /// Failure of `getSpecialities`; the screen picks the view from its type.
  final ApiFailure<dynamic>? failure;

  const AllSpecialitiesState({
    this.status = ViewStatus.initial,
    this.specialities = const [],
    this.failure,
  });

  @override
  List<Object?> get props => [status, specialities, failure];
}

/// Port of `AllSpecialitiesViewModel`.
class AllSpecialitiesCubit extends Cubit<AllSpecialitiesState> {
  AllSpecialitiesCubit(this._repository) : super(const AllSpecialitiesState());

  final SpecialitiesRepository _repository;

  Future<void> load() async {
    emit(const AllSpecialitiesState(status: ViewStatus.loading));
    final result = await _repository.getSpecialities();
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(
          AllSpecialitiesState(status: ViewStatus.success, specialities: data),
        );
      case ApiFailure():
        emit(AllSpecialitiesState(status: ViewStatus.failure, failure: result));
    }
  }
}
