import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../../core/network/endpoints.dart';
import '../models/requests/favorite_request.dart';
import '../models/responses/doctor.dart';
import 'repository_parsers.dart';

class DoctorRepository {
  DoctorRepository(this._api);

  final ApiClient _api;

  Future<ApiResult<DoctorModel>> getDoctor(int id) =>
      _api.get(Endpoints.doctor(id), parse: parseObject(DoctorModel.fromJson));

  Future<ApiResult<void>> toggleFavorite(int id) => _api.post(
    Endpoints.fav,
    body: ToggleFavoriteRequest(id).toJson(),
    parse: parseVoid,
  );
}
