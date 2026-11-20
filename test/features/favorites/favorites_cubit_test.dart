import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/responses/doctor.dart';
import 'package:lavender/data/repositories/favorites_repository.dart';
import 'package:lavender/features/favorites/favorites_cubit.dart';

class _FakeRepo implements FavoritesRepository {
  ApiResult<List<DoctorModel>> listResult = const ApiSuccess([
    DoctorModel(id: 1, isFav: true),
    DoctorModel(id: 2, isFav: true),
  ]);
  ApiResult<void> toggleResult = const ApiSuccess(null);
  final List<String?> names = [];
  final List<int> toggled = [];

  @override
  Future<ApiResult<List<DoctorModel>>> getFavorites({String? name}) async {
    names.add(name);
    return listResult;
  }

  @override
  Future<ApiResult<void>> toggleFavorite(int id) async {
    toggled.add(id);
    return toggleResult;
  }
}

void main() {
  test('load emits success with the doctors and no keyword', () async {
    final repo = _FakeRepo();
    final cubit = FavoritesCubit(repo);
    await cubit.load();
    expect(cubit.state.status, ViewStatus.success);
    expect(cubit.state.doctors.map((d) => d.id), [1, 2]);
    expect(cubit.state.keyword, isNull);
    expect(repo.names, [null]);
  });

  test('un-favorite removes the row after the API succeeds', () async {
    final repo = _FakeRepo();
    final cubit = FavoritesCubit(repo);
    await cubit.load();
    await cubit.unfavorite(0);
    expect(repo.toggled, [1]);
    expect(cubit.state.doctors.map((d) => d.id), [2]);
    expect(cubit.state.toggleFailure, isNull);
  });

  test('a failed un-favorite keeps the row and reports the failure', () async {
    final repo = _FakeRepo()..toggleResult = const ServerFailure(500, 'boom');
    final cubit = FavoritesCubit(repo);
    await cubit.load();
    await cubit.unfavorite(1);
    expect(cubit.state.doctors.map((d) => d.id), [1, 2]);
    expect(cubit.state.doctors[1].isFav, isTrue);
    expect(cubit.state.toggleFailure, isA<ServerFailure>());
    cubit.consumeToggleFailure();
    expect(cubit.state.toggleFailure, isNull);
  });

  test('removing the last row leaves an empty list with no keyword', () async {
    final repo = _FakeRepo()
      ..listResult = const ApiSuccess([DoctorModel(id: 1, isFav: true)]);
    final cubit = FavoritesCubit(repo);
    await cubit.load();
    await cubit.unfavorite(0);
    expect(cubit.state.doctors, isEmpty);
    expect(cubit.state.keyword, isNull);
  });

  test('a keyword is trimmed and kept; blank clears it', () async {
    final repo = _FakeRepo()..listResult = const ApiSuccess([]);
    final cubit = FavoritesCubit(repo);
    await cubit.setKeyword('  ali ');
    expect(cubit.state.keyword, 'ali');
    expect(cubit.state.doctors, isEmpty);
    await cubit.load();
    await cubit.setKeyword('   ');
    expect(cubit.state.keyword, isNull);
    expect(repo.names, ['ali', 'ali', null]);
  });

  test('a failed load keeps the failure', () async {
    final repo = _FakeRepo()..listResult = const NetworkFailure();
    final cubit = FavoritesCubit(repo);
    await cubit.load();
    expect(cubit.state.status, ViewStatus.failure);
    expect(cubit.state.failure, isA<NetworkFailure>());
  });
}
