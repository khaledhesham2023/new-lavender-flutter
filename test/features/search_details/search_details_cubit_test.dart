import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/responses/doctor.dart';
import 'package:lavender/data/models/responses/speciality.dart';
import 'package:lavender/data/repositories/home_repository.dart';
import 'package:lavender/data/repositories/specialities_repository.dart';
import 'package:lavender/features/search_details/search_details_cubit.dart';
import 'package:lavender/features/search_details/search_filter.dart';

class _Call {
  final int specialtyId;
  final String? sortBy;
  final List<int> subSpecialtyIds;
  final String? gender;
  final double? maxPrice;
  final double? minPrice;
  final String? name;

  _Call(
    this.specialtyId,
    this.sortBy,
    this.subSpecialtyIds,
    this.gender,
    this.maxPrice,
    this.minPrice,
    this.name,
  );
}

class _FakeSpecialitiesRepository implements SpecialitiesRepository {
  ApiResult<DoctorsBySpecialityData> result = const ApiSuccess(
    DoctorsBySpecialityData(),
  );
  final List<_Call> calls = [];

  @override
  Future<ApiResult<DoctorsBySpecialityData>> getDoctors(
    int specialtyId, {
    String? sortBy,
    List<int> subSpecialtyIds = const [],
    String? gender,
    double? maxPrice,
    double? minPrice,
    String? name,
  }) async {
    calls.add(
      _Call(
        specialtyId,
        sortBy,
        subSpecialtyIds,
        gender,
        maxPrice,
        minPrice,
        name,
      ),
    );
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHomeRepository implements HomeRepository {
  ApiResult<void> favoriteResult = const ApiSuccess(null);
  final List<int> favoriteCalls = [];

  @override
  Future<ApiResult<void>> toggleFavorite(int doctorId) async {
    favoriteCalls.add(doctorId);
    return favoriteResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<DoctorModel> _doctors() => const [
  DoctorModel(id: 1, name: 'A'),
  DoctorModel(id: 2, name: 'B', isFav: true),
];

(SearchDetailsCubit, _FakeSpecialitiesRepository, _FakeHomeRepository) _make() {
  final specialities = _FakeSpecialitiesRepository()
    ..result = ApiSuccess(DoctorsBySpecialityData(doctors: _doctors(), count: 2));
  final home = _FakeHomeRepository();
  final cubit = SearchDetailsCubit(
    specialities,
    home,
    const SpecialityModel(id: 7, name: 'Dental'),
  );
  return (cubit, specialities, home);
}

void main() {
  group('SearchFilter', () {
    test('hasFilter is false for the default and for sort alone', () {
      expect(const SearchFilter().hasFilter, isFalse);
      expect(const SearchFilter(sortBy: 'high_to_low_price').hasFilter, isFalse);
    });

    test('hasFilter is true for each criterion', () {
      expect(const SearchFilter(gender: 'male').hasFilter, isTrue);
      expect(const SearchFilter(minPrice: 10).hasFilter, isTrue);
      expect(const SearchFilter(maxPrice: 10).hasFilter, isTrue);
      expect(
        const SearchFilter(subSpecialties: [SubSpecialtyModel(id: 1)]).hasFilter,
        isTrue,
      );
    });

    test('copyWith can set and clear nullable fields', () {
      const filter = SearchFilter(gender: 'male', sortBy: 'x');
      expect(filter.copyWith(sortBy: () => null).sortBy, isNull);
      expect(filter.copyWith(sortBy: () => null).gender, 'male');
      expect(filter.copyWith(minPrice: () => 5).minPrice, 5);
    });

    test('cleared drops the filters but keeps the sort', () {
      const filter = SearchFilter(
        gender: 'male',
        minPrice: 1,
        maxPrice: 2,
        subSpecialties: [SubSpecialtyModel(id: 1)],
        sortBy: 'low_to_high_rate',
      );
      expect(filter.cleared(), const SearchFilter(sortBy: 'low_to_high_rate'));
    });
  });

  group('SearchDetailsCubit', () {
    test('load requests the speciality without filters and fills the state', () async {
      final (cubit, repo, _) = _make();
      await cubit.load();
      final call = repo.calls.single;
      expect(call.specialtyId, 7);
      expect(call.sortBy, isNull);
      expect(call.subSpecialtyIds, isEmpty);
      expect(call.name, isNull);
      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.doctors.length, 2);
      expect(cubit.state.count, 2);
    });

    test('applyFilter sends gender, prices and sub-specialty ids', () async {
      final (cubit, repo, _) = _make();
      await cubit.applyFilter(
        const SearchFilter(
          subSpecialties: [
            SubSpecialtyModel(id: 3),
            SubSpecialtyModel(id: 9),
          ],
          gender: 'female',
          minPrice: 50,
          maxPrice: 150.5,
        ),
      );
      final call = repo.calls.single;
      expect(call.subSpecialtyIds, [3, 9]);
      expect(call.gender, 'female');
      expect(call.minPrice, 50.0);
      expect(call.maxPrice, 150.5);
      expect(cubit.state.filter.hasFilter, isTrue);
    });

    test('setSort sends the value, keeps the filter, and null clears it', () async {
      final (cubit, repo, _) = _make();
      await cubit.applyFilter(const SearchFilter(gender: 'male'));
      await cubit.setSort('high_to_low_price');
      expect(repo.calls.last.sortBy, 'high_to_low_price');
      expect(repo.calls.last.gender, 'male');
      expect(cubit.state.filter.sortBy, 'high_to_low_price');

      await cubit.setSort(null);
      expect(repo.calls.last.sortBy, isNull);
      expect(cubit.state.filter.sortBy, isNull);
    });

    test('setName trims, and blank text removes the name filter', () async {
      final (cubit, repo, _) = _make();
      await cubit.setName('  Ali ');
      expect(repo.calls.last.name, 'Ali');
      expect(cubit.state.name, 'Ali');

      await cubit.setName('   ');
      expect(repo.calls.last.name, isNull);
      expect(cubit.state.name, isNull);
    });

    test('name, sort and filter are all sent together', () async {
      final (cubit, repo, _) = _make();
      await cubit.setName('Ali');
      await cubit.setSort('low_to_high_rate');
      await cubit.applyFilter(
        cubit.state.filter.copyWith(gender: () => 'male'),
      );
      final call = repo.calls.last;
      expect(call.name, 'Ali');
      expect(call.sortBy, 'low_to_high_rate');
      expect(call.gender, 'male');
    });

    test('a failed load sets the failure status', () async {
      final (cubit, repo, _) = _make();
      repo.result = const NetworkFailure();
      await cubit.load();
      expect(cubit.state.status, ViewStatus.failure);
      expect(cubit.state.failure, isA<NetworkFailure<dynamic>>());
    });

    test('an empty answer gives an empty list with count 0', () async {
      final (cubit, repo, _) = _make();
      repo.result = const ApiSuccess(DoctorsBySpecialityData());
      await cubit.load();
      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.doctors, isEmpty);
      expect(cubit.state.count, 0);
    });

    test('toggleFavorite flips the heart and calls the API', () async {
      final (cubit, _, home) = _make();
      await cubit.load();
      await cubit.toggleFavorite(0);
      expect(home.favoriteCalls, [1]);
      expect(cubit.state.doctors[0].isFav, isTrue);
      expect(cubit.state.favoriteFailure, isNull);
    });

    test('toggleFavorite reverts and reports on failure', () async {
      final (cubit, _, home) = _make();
      await cubit.load();
      home.favoriteResult = const ServerFailure(500, 'boom');
      await cubit.toggleFavorite(1); // was a favorite
      expect(cubit.state.doctors[1].isFav, isTrue);
      expect(cubit.state.favoriteFailure, isA<ServerFailure<void>>());

      cubit.consumeFavoriteFailure();
      expect(cubit.state.favoriteFailure, isNull);
    });
  });
}
