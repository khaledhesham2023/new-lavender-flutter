import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../data/models/responses/search.dart';
import '../../../data/models/responses/speciality.dart';
import '../../../data/repositories/repository_parsers.dart';
import '../../domain/repositories/search_repository.dart';

/// [SearchRepository] over the Lavender API.
class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<ApiResult<List<SpecialityModel>>> mostSelected() => _api.call(
    (s) => s.searchMost(),
    parse: parseList(SpecialityModel.fromJson),
  );

  @override
  Future<ApiResult<List<RecentSearchModel>>> recent() => _api.call(
    (s) => s.recentSearches(),
    parse: parseList(RecentSearchModel.fromJson),
  );

  /// The keyword goes in the query string; no body is sent.
  @override
  Future<ApiResult<SearchResultsData>> search(String keyword) => _api.call(
    (s) => s.search(keyword),
    parse: parseObject(SearchResultsData.fromJson),
  );

  @override
  Future<ApiResult<void>> clearRecent() =>
      _api.call((s) => s.clearSearch(), parse: parseVoid);

  @override
  Future<ApiResult<FilterData>> filterDetails(int specialtyId) => _api.call(
    (s) => s.filterDetails(specialtyId),
    parse: parseObject(FilterData.fromJson),
  );
}
