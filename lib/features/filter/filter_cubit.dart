import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../data/models/responses/speciality.dart';
import '../../data/repositories/search_repository.dart';
import '../../router/route_args.dart';
import '../search_details/search_filter.dart';

class FilterState extends Equatable {
  final ViewStatus status;

  /// Subspecialties and price bounds of the speciality (null until loaded).
  final FilterData? data;

  /// Working copy edited on the screen; only "Show results" returns it.
  final SearchFilter filter;
  final ApiFailure<dynamic>? failure;

  const FilterState({
    this.status = ViewStatus.initial,
    this.data,
    this.filter = const SearchFilter(),
    this.failure,
  });

  List<SubSpecialtyModel> get allSubSpecialties =>
      data?.specialties ?? const [];

  double get minPrice => data?.minPrice ?? 0;
  double get maxPrice => data?.maxPrice ?? 0;

  /// Android shows the price slider only when the bounds differ.
  bool get hasPriceRange => data != null && minPrice != maxPrice;

  /// Slider position: the chosen value clamped to `[minPrice, maxPrice]`
  /// (the backend bounds can move after the filter was stored).
  RangeValuesPair get priceValues {
    final low = (filter.minPrice ?? minPrice).clamp(minPrice, maxPrice);
    final high = (filter.maxPrice ?? maxPrice).clamp(minPrice, maxPrice);
    return low <= high ? (low, high) : (high, low);
  }

  FilterState copyWith({
    ViewStatus? status,
    FilterData? data,
    SearchFilter? filter,
    ApiFailure<dynamic>? failure,
    bool clearFailure = false,
  }) {
    return FilterState(
      status: status ?? this.status,
      data: data ?? this.data,
      filter: filter ?? this.filter,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, data, filter, failure];
}

typedef RangeValuesPair = (double, double);

/// Port of the filter logic of `FilterFragment` + `SearchDetailsViewModel
/// .GetFilterResults`. Edits a working copy of the [SearchFilter]; the screen
/// pops it on Apply, and pops nothing on back (the caller keeps its filter).
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
