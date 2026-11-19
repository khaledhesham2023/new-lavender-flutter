import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../models/responses/search.dart';
import '../models/responses/speciality.dart';
import 'repository_parsers.dart';

class SearchRepository {
  SearchRepository(this._api);

  final ApiClient _api;

  Future<ApiResult<List<SpecialityModel>>> mostSelected() => _api.call(
    (s) => s.searchMost(),
    parse: parseList(SpecialityModel.fromJson),
  );

  Future<ApiResult<List<RecentSearchModel>>> recent() => _api.call(
    (s) => s.recentSearches(),
    parse: parseList(RecentSearchModel.fromJson),
  );

  /// The keyword goes in the query string; no body is sent.
  Future<ApiResult<SearchResultsData>> search(String keyword) => _api.call(
    (s) => s.search(keyword),
    parse: parseObject(SearchResultsData.fromJson),
  );

  Future<ApiResult<void>> clearRecent() =>
      _api.call((s) => s.clearSearch(), parse: parseVoid);

  Future<ApiResult<FilterData>> filterDetails(int specialtyId) => _api.call(
    (s) => s.filterDetails(specialtyId),
    parse: parseObject(FilterData.fromJson),
  );
}
