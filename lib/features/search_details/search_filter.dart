import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/responses/speciality.dart';

/// Filters + sort of the doctors list (Android `SearchDetailsSharedViewModel`).
/// Travels to the Filter screen (T21) in `FilterArgs` and comes back as the
/// result; it is never global state.
class SearchFilter extends Equatable {
  final List<SubSpecialtyModel> subSpecialties;
  final String? gender;
  final double? minPrice;
  final double? maxPrice;

  /// `SortByStatus.value`; not part of [hasFilter] (the sort has its own dot).
  final String? sortBy;

  const SearchFilter({
    this.subSpecialties = const [],
    this.gender,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
  });

  /// Port of `checkRedBadgeVisibility`.
  bool get hasFilter =>
      gender != null ||
      minPrice != null ||
      maxPrice != null ||
      subSpecialties.isNotEmpty;

  /// A nullable field is changed by passing a getter, so `null` can be set:
  /// `copyWith(sortBy: () => null)` clears the sort.
  SearchFilter copyWith({
    List<SubSpecialtyModel>? subSpecialties,
    ValueGetter<String?>? gender,
    ValueGetter<double?>? minPrice,
    ValueGetter<double?>? maxPrice,
    ValueGetter<String?>? sortBy,
  }) {
    return SearchFilter(
      subSpecialties: subSpecialties ?? this.subSpecialties,
      gender: gender != null ? gender() : this.gender,
      minPrice: minPrice != null ? minPrice() : this.minPrice,
      maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
      sortBy: sortBy != null ? sortBy() : this.sortBy,
    );
  }

  /// Drops every filter (the Filter screen's Reset) but keeps the sort.
  SearchFilter cleared() => SearchFilter(sortBy: sortBy);

  @override
  List<Object?> get props => [
    subSpecialties,
    gender,
    minPrice,
    maxPrice,
    sortBy,
  ];
}
