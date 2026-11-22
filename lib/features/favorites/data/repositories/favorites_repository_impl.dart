import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../data/models/requests/favorite_request.dart';
import '../../../../data/models/responses/doctor.dart';
import '../../../../data/repositories/repository_parsers.dart';
import '../../domain/repositories/favorites_repository.dart';

/// [FavoritesRepository] over the Lavender API.
class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<ApiResult<List<DoctorModel>>> getFavorites({String? name}) =>
      _api.call(
        (s) => s.favorites(doctorName: name),
        parse: parseList(DoctorModel.fromJson),
      );

  @override
  Future<ApiResult<void>> toggleFavorite(int id) => _api.call(
    (s) => s.toggleFavorite(ToggleFavoriteRequest(id).toJson()),
    parse: parseVoid,
  );
}
