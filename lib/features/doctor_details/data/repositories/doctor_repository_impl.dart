import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../data/models/requests/favorite_request.dart';
import '../../../../data/models/responses/doctor.dart';
import '../../../../data/repositories/repository_parsers.dart';
import '../../domain/repositories/doctor_repository.dart';

/// [DoctorRepository] over the Lavender API.
class DoctorRepositoryImpl implements DoctorRepository {
  DoctorRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<ApiResult<DoctorModel>> getDoctor(int id) =>
      _api.call((s) => s.doctor(id), parse: parseObject(DoctorModel.fromJson));

  @override
  Future<ApiResult<void>> toggleFavorite(int id) => _api.call(
    (s) => s.toggleFavorite(ToggleFavoriteRequest(id).toJson()),
    parse: parseVoid,
  );
}
