import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../../core/network/endpoints.dart';
import '../models/responses/search.dart';
import '../models/responses/speciality.dart';
import 'repository_parsers.dart';

class SearchRepository {
  SearchRepository(this._api);

  final ApiClient _api;

  Future<ApiResult<List<SpecialityModel>>> mostSelected() => _api.get(
    Endpoints.searchMost,
    parse: parseList(SpecialityModel.fromJson),
  );

  Future<ApiResult<List<RecentSearchModel>>> recent() =>
      _api.get(Endpoints.search, parse: parseList(RecentSearchModel.fromJson));

  /// The keyword goes in the query string; no body is sent.
  Future<ApiResult<SearchResultsData>> search(String keyword) => _api.post(
    Endpoints.search,
    query: {'keyword': keyword},
    parse: parseObject(SearchResultsData.fromJson),
  );

  Future<ApiResult<void>> clearRecent() =>
      _api.delete(Endpoints.searchClear, parse: parseVoid);

  Future<ApiResult<FilterData>> filterDetails(int specialtyId) => _api.get(
    Endpoints.filterDetails(specialtyId),
    parse: parseObject(FilterData.fromJson),
  );
}
