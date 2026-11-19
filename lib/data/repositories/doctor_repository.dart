import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../models/requests/favorite_request.dart';
import '../models/responses/doctor.dart';
import 'repository_parsers.dart';

class DoctorRepository {
  DoctorRepository(this._api);

  final ApiClient _api;

  Future<ApiResult<DoctorModel>> getDoctor(int id) =>
      _api.call((s) => s.doctor(id), parse: parseObject(DoctorModel.fromJson));

  Future<ApiResult<void>> toggleFavorite(int id) => _api.call(
    (s) => s.toggleFavorite(ToggleFavoriteRequest(id).toJson()),
    parse: parseVoid,
  );
}
