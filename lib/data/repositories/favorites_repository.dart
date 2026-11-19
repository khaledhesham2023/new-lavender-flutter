import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../models/requests/favorite_request.dart';
import '../models/responses/doctor.dart';
import 'repository_parsers.dart';

class FavoritesRepository {
  FavoritesRepository(this._api);

  final ApiClient _api;

  Future<ApiResult<List<DoctorModel>>> getFavorites({String? name}) =>
      _api.call(
        (s) => s.favorites(doctorName: name),
        parse: parseList(DoctorModel.fromJson),
      );

  Future<ApiResult<void>> toggleFavorite(int id) => _api.call(
    (s) => s.toggleFavorite(ToggleFavoriteRequest(id).toJson()),
    parse: parseVoid,
  );
}
