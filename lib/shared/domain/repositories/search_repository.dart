import '../../../core/network/api_result.dart';
import '../../../data/models/responses/search.dart';
import '../../../data/models/responses/speciality.dart';

/// Search and filter data, used by search and filter.
/// `SearchRepositoryImpl` (shared data layer) implements it.
abstract interface class SearchRepository {
  Future<ApiResult<List<SpecialityModel>>> mostSelected();

  Future<ApiResult<List<RecentSearchModel>>> recent();

  Future<ApiResult<SearchResultsData>> search(String keyword);

  Future<ApiResult<void>> clearRecent();

  Future<ApiResult<FilterData>> filterDetails(int specialtyId);
}
