import '../../../../core/network/api_result.dart';
import '../../../../data/models/responses/doctor.dart';

/// What the favorites feature needs from the outside world. The presentation
/// layer depends on this contract only; `FavoritesRepositoryImpl` (data layer)
/// implements it.
///
/// `DoctorModel` stands in for a `Doctor` entity until the shared models get
/// their own entities.
abstract interface class FavoritesRepository {
  /// The user's favorite doctors, filtered by [name] when given.
  Future<ApiResult<List<DoctorModel>>> getFavorites({String? name});

  /// Adds or removes the doctor [id] from the favorites.
  Future<ApiResult<void>> toggleFavorite(int id);
}
