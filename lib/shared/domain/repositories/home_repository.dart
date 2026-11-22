import '../../../core/network/api_result.dart';
import '../../../data/models/responses/home.dart';

/// Home data, used by home and search_details. `HomeRepositoryImpl` (shared
/// data layer) implements it.
abstract interface class HomeRepository {
  Future<ApiResult<HomeData>> getHome();

  /// Toggles the favorite state of the doctor [doctorId].
  Future<ApiResult<void>> toggleFavorite(int doctorId);
}
