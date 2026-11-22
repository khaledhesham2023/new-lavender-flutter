import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../data/models/responses/speciality.dart';
import '../../../shared/domain/repositories/specialities_repository.dart';
import 'all_specialities_state.dart';

List<SpecialityModel> buildAllSpecialities(
  List<SpecialityModel> specialities,
  String medicalOffersLabel,
) {
  return [SpecialityModel(id: 0, name: medicalOffersLabel), ...specialities];
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
