import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../../core/network/endpoints.dart';
import '../models/responses/speciality.dart';
import 'repository_parsers.dart';

class SpecialitiesRepository {
  SpecialitiesRepository(this._api);

  final ApiClient _api;

  Future<ApiResult<List<SpecialityModel>>> getSpecialities() => _api.get(
    Endpoints.specialties,
    parse: parseList(SpecialityModel.fromJson),
  );

  /// Null filters are dropped. Sub-specialties are sent as
  /// `sub_specialty[0]=<id>` with unencoded brackets. Prices are sent like
  /// Kotlin `Float.toString()` (e.g. `150.0`).
  Future<ApiResult<DoctorsBySpecialityData>> getDoctors(
    int specialtyId, {
    String? sortBy,
    List<int> subSpecialtyIds = const [],
    String? gender,
    double? maxPrice,
    double? minPrice,
    String? name,
  }) => _api.get(
    Endpoints.specialtyDoctors(specialtyId),
    rawQuery: buildQuery({
      'sort_by': sortBy,
      'gender': gender,
      'max_price': maxPrice,
      'min_price': minPrice,
      'doctor_name': name,
      for (var i = 0; i < subSpecialtyIds.length; i++)
        'sub_specialty[$i]': subSpecialtyIds[i],
    }),
    parse: parseObject(DoctorsBySpecialityData.fromJson),
  );
}
