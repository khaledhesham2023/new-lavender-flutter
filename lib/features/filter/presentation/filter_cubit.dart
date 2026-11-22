import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../data/models/responses/speciality.dart';
import '../../../shared/domain/repositories/search_repository.dart';
import '../../../app/router/route_args.dart';
import 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit(this._repository, this.args)
    : super(FilterState(filter: args.current));

  final SearchRepository _repository;
  final FilterArgs args;

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading, clearFailure: true));
    final result = await _repository.filterDetails(args.specialtyId);
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: ViewStatus.success, data: data));
      case ApiFailure():
        emit(state.copyWith(status: ViewStatus.failure, failure: result));
    }
  }

  void setPriceRange(double min, double max) => emit(
    state.copyWith(
      filter: state.filter.copyWith(minPrice: () => min, maxPrice: () => max),
    ),
  );

  void setGender(String? gender) =>
      emit(state.copyWith(filter: state.filter.copyWith(gender: () => gender)));

  void setSubSpecialties(List<SubSpecialtyModel> subSpecialties) => emit(
    state.copyWith(
      filter: state.filter.copyWith(subSpecialties: subSpecialties),
    ),
  );

  /// "Remove all": clears gender, price and subspecialties (keeps the sort).
  void reset() => emit(state.copyWith(filter: state.filter.cleared()));
}
