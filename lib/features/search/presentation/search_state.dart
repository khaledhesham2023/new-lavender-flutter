import 'package:equatable/equatable.dart';

import '../../../core/network/api_result.dart';
import '../../../data/models/responses/search.dart';
import '../../../data/models/responses/speciality.dart';
import 'search_mode.dart';

class SearchState extends Equatable {
  final SearchMode mode;

  /// Status of the request behind the current [mode]. `loading` hides every
  /// body (Android shows only the loader); `failure` shows the error view.
  final ViewStatus status;
  final ApiFailure<dynamic>? failure;

  final List<SpecialityModel> mostSelected;
  final List<RecentSearchModel> recent;
  final SearchResultsData results;

  const SearchState({
    this.mode = SearchMode.mostSelected,
    this.status = ViewStatus.initial,
    this.failure,
    this.mostSelected = const [],
    this.recent = const [],
    this.results = const SearchResultsData(),
  });

  SearchState copyWith({
    SearchMode? mode,
    ViewStatus? status,
    ApiFailure<dynamic>? failure,
    bool clearFailure = false,
    List<SpecialityModel>? mostSelected,
    List<RecentSearchModel>? recent,
    SearchResultsData? results,
  }) {
    return SearchState(
      mode: mode ?? this.mode,
      status: status ?? this.status,
      failure: clearFailure ? null : (failure ?? this.failure),
      mostSelected: mostSelected ?? this.mostSelected,
      recent: recent ?? this.recent,
      results: results ?? this.results,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    status,
    failure,
    mostSelected,
    recent,
    results,
  ];
}
