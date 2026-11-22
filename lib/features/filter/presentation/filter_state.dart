import 'package:equatable/equatable.dart';

import '../../../core/network/api_result.dart';
import '../../../data/models/responses/speciality.dart';
import '../../../shared/domain/entities/search_filter.dart';

typedef RangeValuesPair = (double, double);

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
