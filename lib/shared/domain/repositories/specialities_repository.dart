import '../../../core/network/api_result.dart';
import '../../../data/models/responses/speciality.dart';

/// Specialities and their doctors, used by specialities, offers and
/// search_details. `SpecialitiesRepositoryImpl` (shared data layer) implements
/// it.
abstract interface class SpecialitiesRepository {
  Future<ApiResult<List<SpecialityModel>>> getSpecialities();

  /// Doctors of [specialtyId]; null filters are not sent.
  Future<ApiResult<DoctorsBySpecialityData>> getDoctors(
    int specialtyId, {
    String? sortBy,
    List<int> subSpecialtyIds = const [],
    String? gender,
    double? maxPrice,
    double? minPrice,
    String? name,
  });
}
