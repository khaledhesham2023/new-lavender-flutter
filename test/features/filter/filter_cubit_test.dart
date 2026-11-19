import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/responses/speciality.dart';
import 'package:lavender/data/repositories/search_repository.dart';
import 'package:lavender/features/filter/filter_cubit.dart';
import 'package:lavender/features/search_details/search_filter.dart';
import 'package:lavender/router/route_args.dart';

class _FakeSearchRepository implements SearchRepository {
  ApiResult<FilterData> result = const ApiSuccess(FilterData());
  final List<int> calls = [];

  @override
  Future<ApiResult<FilterData>> filterDetails(int specialtyId) async {
    calls.add(specialtyId);
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _subs = [
  SubSpecialtyModel(id: 1, name: 'A'),
  SubSpecialtyModel(id: 2, name: 'B'),
];

FilterCubit _make({
  SearchFilter current = const SearchFilter(),
  FilterData data = const FilterData(
    specialties: _subs,
    minPrice: 100,
    maxPrice: 500,
  ),
}) {
  final repo = _FakeSearchRepository()..result = ApiSuccess(data);
  return FilterCubit(repo, FilterArgs(7, current));
}

void main() {
  test('load requests the speciality and fills the data', () async {
    final repo = _FakeSearchRepository()
      ..result = const ApiSuccess(
        FilterData(specialties: _subs, minPrice: 100, maxPrice: 500),
      );
    final cubit = FilterCubit(repo, const FilterArgs(7, SearchFilter()));
    await cubit.load();
    expect(repo.calls, [7]);
    expect(cubit.state.status, ViewStatus.success);
    expect(cubit.state.allSubSpecialties, _subs);
    expect(cubit.state.hasPriceRange, isTrue);
  });

  test('load failure keeps the failure', () async {
    final repo = _FakeSearchRepository()..result = const NetworkFailure();
    final cubit = FilterCubit(repo, const FilterArgs(7, SearchFilter()));
    await cubit.load();
    expect(cubit.state.status, ViewStatus.failure);
    expect(cubit.state.failure, isA<NetworkFailure<FilterData>>());
  });

  test('the working copy starts from the current filter', () {
    final cubit = _make(
      current: const SearchFilter(gender: 'male', sortBy: 'x'),
    );
    expect(cubit.state.filter.gender, 'male');
  });

  test('no price slider when min equals max', () async {
    final cubit = _make(data: const FilterData(minPrice: 200, maxPrice: 200));
    await cubit.load();
    expect(cubit.state.hasPriceRange, isFalse);
  });

  test('price values default to the full range and are clamped', () async {
    final cubit = _make();
    await cubit.load();
    expect(cubit.state.priceValues, (100.0, 500.0));
    cubit.setPriceRange(50, 900);
    expect(cubit.state.priceValues, (100.0, 500.0));
    cubit.setPriceRange(200, 300);
    expect(cubit.state.priceValues, (200.0, 300.0));
  });

  test('setGender, setSubSpecialties and setPriceRange edit the copy', () {
    final cubit = _make();
    cubit.setGender('female');
    cubit.setSubSpecialties(const [SubSpecialtyModel(id: 2, name: 'B')]);
    cubit.setPriceRange(150, 250);
    expect(
      cubit.state.filter,
      const SearchFilter(
        gender: 'female',
        subSpecialties: [SubSpecialtyModel(id: 2, name: 'B')],
        minPrice: 150,
        maxPrice: 250,
      ),
    );
  });

  test('reset clears the filters but keeps the sort', () {
    final cubit = _make(
      current: const SearchFilter(
        gender: 'male',
        minPrice: 1,
        maxPrice: 2,
        subSpecialties: _subs,
        sortBy: 'low_to_high_rate',
      ),
    );
    cubit.reset();
    expect(cubit.state.filter, const SearchFilter(sortBy: 'low_to_high_rate'));
    expect(cubit.state.filter.hasFilter, isFalse);
  });
}
