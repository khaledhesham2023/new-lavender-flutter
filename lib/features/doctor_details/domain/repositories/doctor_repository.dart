import '../../../../core/network/api_result.dart';
import '../../../../data/models/responses/doctor.dart';

/// What the doctor details feature needs from the outside world. The
/// presentation layer depends on this contract only; `DoctorRepositoryImpl`
/// (data layer) implements it.
///
/// `DoctorModel` stands in for a `Doctor` entity until the shared models get
/// their own entities.
abstract interface class DoctorRepository {
  /// The doctor [id] with work times, reviews, offers and certificates.
  Future<ApiResult<DoctorModel>> getDoctor(int id);

  /// Adds or removes the doctor [id] from the favorites.
  Future<ApiResult<void>> toggleFavorite(int id);
}
