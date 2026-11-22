import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../data/models/responses/speciality.dart';
import '../../../data/repositories/repository_parsers.dart';
import '../../domain/repositories/specialities_repository.dart';

/// [SpecialitiesRepository] over the Lavender API.
class SpecialitiesRepositoryImpl implements SpecialitiesRepository {
  SpecialitiesRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<ApiResult<List<SpecialityModel>>> getSpecialities() => _api.call(
    (s) => s.specialties(),
    parse: parseList(SpecialityModel.fromJson),
  );

  /// Null filters are dropped. Sub-specialties are sent as
  /// `sub_specialty[0]=<id>` (Dio percent-encodes the brackets; the server
  /// decodes them). Prices are sent like Kotlin `Float.toString()` (e.g.
  /// `150.0`).
  @override
  Future<ApiResult<DoctorsBySpecialityData>> getDoctors(
    int specialtyId, {
    String? sortBy,
    List<int> subSpecialtyIds = const [],
    String? gender,
    double? maxPrice,
    double? minPrice,
    String? name,
  }) => _api.call(
    (s) => s.specialtyDoctors(specialtyId, {
      'sort_by': sortBy,
      'gender': gender,
      'max_price': maxPrice,
      'min_price': minPrice,
      'doctor_name': name,
      for (var i = 0; i < subSpecialtyIds.length; i++)
        'sub_specialty[$i]': subSpecialtyIds[i],
    }..removeWhere((_, v) => v == null)),
    parse: parseObject(DoctorsBySpecialityData.fromJson),
  );
}
