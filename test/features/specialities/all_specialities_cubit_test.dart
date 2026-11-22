import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/responses/speciality.dart';
import 'package:lavender/shared/domain/repositories/specialities_repository.dart';
import 'package:lavender/features/specialities/all_specialities_cubit.dart';

class _FakeSpecialitiesRepository implements SpecialitiesRepository {
  ApiResult<List<SpecialityModel>> result = const ApiSuccess([]);
  int calls = 0;

  @override
  Future<ApiResult<List<SpecialityModel>>> getSpecialities() async {
    calls++;
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<SpecialityModel> _specialities(int n) => [
  for (var i = 1; i <= n; i++) SpecialityModel(id: i, name: 'S$i'),
];

void main() {
  group('buildAllSpecialities', () {
    test('offers tile first, then every speciality (no cap, no More)', () {
      final list = buildAllSpecialities(_specialities(20), 'Offers');
      expect(list, hasLength(21));
      expect(list.first.id, 0);
      expect(list.first.name, 'Offers');
      expect(list.last.id, 20);
    });

    test('empty input leaves only the offers tile', () {
      expect(buildAllSpecialities(const [], 'Offers'), hasLength(1));
    });
  });

  group('AllSpecialitiesCubit', () {
    test('load success -> success with specialities', () async {
      final repo = _FakeSpecialitiesRepository()
        ..result = ApiSuccess(_specialities(3));
      final cubit = AllSpecialitiesCubit(repo);

      await cubit.load();

      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.specialities, hasLength(3));
      expect(cubit.state.failure, isNull);
    });

    test('load failure -> failure with the failure kept', () async {
      final repo = _FakeSpecialitiesRepository()
        ..result = const NetworkFailure<List<SpecialityModel>>();
      final cubit = AllSpecialitiesCubit(repo);

      await cubit.load();

      expect(cubit.state.status, ViewStatus.failure);
      expect(cubit.state.failure, isA<NetworkFailure<dynamic>>());
    });

    test('retry after a failure reloads', () async {
      final repo = _FakeSpecialitiesRepository()
        ..result = const NetworkFailure<List<SpecialityModel>>();
      final cubit = AllSpecialitiesCubit(repo);
      await cubit.load();

      repo.result = ApiSuccess(_specialities(2));
      await cubit.load();

      expect(repo.calls, 2);
      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.failure, isNull);
    });
  });
}
