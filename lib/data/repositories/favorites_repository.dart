import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../../core/network/endpoints.dart';
import '../models/requests/favorite_request.dart';
import '../models/responses/doctor.dart';
import 'repository_parsers.dart';

class FavoritesRepository {
  FavoritesRepository(this._api);

  final ApiClient _api;

  Future<ApiResult<List<DoctorModel>>> getFavorites({String? name}) => _api.get(
    Endpoints.fav,
    query: {'doctor_name': name},
    parse: parseList(DoctorModel.fromJson),
  );

  Future<ApiResult<void>> toggleFavorite(int id) => _api.post(
    Endpoints.fav,
    body: ToggleFavoriteRequest(id).toJson(),
    parse: parseVoid,
  );
}
