import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/responses/offer.dart';
import 'package:lavender/data/models/responses/speciality.dart';
import 'package:lavender/shared/domain/repositories/offers_repository.dart';
import 'package:lavender/shared/domain/repositories/specialities_repository.dart';
import 'package:lavender/features/offers/offer_details_cubit.dart';
import 'package:lavender/features/offers/offers_cubit.dart';
import 'package:lavender/features/offers/widgets/offer_card.dart';

class _FakeSpecialities implements SpecialitiesRepository {
  ApiResult<List<SpecialityModel>> result = const ApiSuccess([]);

  @override
  Future<ApiResult<List<SpecialityModel>>> getSpecialities() async => result;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOffers implements OffersRepository {
  final Map<int, ApiResult<List<OfferModel>>> bySpecialtyResults = {};
  ApiResult<OfferModel> detailsResult = const ApiSuccess(OfferModel(id: 1));
  final List<int> requested = [];

  @override
  Future<ApiResult<List<OfferModel>>> bySpecialty(int id) async {
    requested.add(id);
    return bySpecialtyResults[id] ?? const ApiSuccess([]);
  }

  @override
  Future<ApiResult<OfferModel>> details(int id) async => detailsResult;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _tabs = [
  SpecialityModel(id: 5, name: 'Dental'),
  SpecialityModel(id: 7, name: 'Skin'),
];

void main() {
  group('OffersCubit', () {
    test('load selects the first tab and loads its offers', () async {
      final specialities = _FakeSpecialities()
        ..result = const ApiSuccess(_tabs);
      final offers = _FakeOffers()
        ..bySpecialtyResults[5] = const ApiSuccess([OfferModel(id: 1)]);
      final cubit = OffersCubit(specialities, offers);

      await cubit.load();

      expect(cubit.state.tabsStatus, ViewStatus.success);
      expect(cubit.state.selectedId, 5);
      expect(cubit.state.listStatus, ViewStatus.success);
      expect(cubit.state.offers.single.id, 1);
      expect(offers.requested, [5]);
    });

    test('tabs failure keeps the failure and skips the list', () async {
      final specialities = _FakeSpecialities()
        ..result = const NetworkFailure<List<SpecialityModel>>();
      final offers = _FakeOffers();
      final cubit = OffersCubit(specialities, offers);

      await cubit.load();

      expect(cubit.state.tabsStatus, ViewStatus.failure);
      expect(cubit.state.tabsFailure, isA<NetworkFailure<dynamic>>());
      expect(offers.requested, isEmpty);
    });

    test('selectTab loads the offers of that specialty', () async {
      final specialities = _FakeSpecialities()
        ..result = const ApiSuccess(_tabs);
      final offers = _FakeOffers()
        ..bySpecialtyResults[7] = const ApiSuccess([
          OfferModel(id: 2),
          OfferModel(id: 3),
        ]);
      final cubit = OffersCubit(specialities, offers);
      await cubit.load();

      await cubit.selectTab(7);

      expect(cubit.state.selectedId, 7);
      expect(cubit.state.offers.map((o) => o.id), [2, 3]);
    });

    test('list failure is independent from the tabs', () async {
      final specialities = _FakeSpecialities()
        ..result = const ApiSuccess(_tabs);
      final offers = _FakeOffers()
        ..bySpecialtyResults[5] = const ServerFailure<List<OfferModel>>(
          500,
          'x',
        );
      final cubit = OffersCubit(specialities, offers);

      await cubit.load();

      expect(cubit.state.tabsStatus, ViewStatus.success);
      expect(cubit.state.listStatus, ViewStatus.failure);
      expect(cubit.state.listFailure, isA<ServerFailure<dynamic>>());
      expect(cubit.state.offers, isEmpty);
    });

    test('empty specialty -> success with no offers', () async {
      final specialities = _FakeSpecialities()
        ..result = const ApiSuccess(_tabs);
      final cubit = OffersCubit(specialities, _FakeOffers());

      await cubit.load();

      expect(cubit.state.listStatus, ViewStatus.success);
      expect(cubit.state.offers, isEmpty);
    });

    test('refresh reloads the selected tab', () async {
      final specialities = _FakeSpecialities()
        ..result = const ApiSuccess(_tabs);
      final offers = _FakeOffers();
      final cubit = OffersCubit(specialities, offers);
      await cubit.load();
      await cubit.selectTab(7);

      await cubit.refresh();

      expect(offers.requested, [5, 7, 7]);
    });
  });

  group('OfferDetailsCubit', () {
    test('load success', () async {
      final cubit = OfferDetailsCubit(_FakeOffers(), 1);

      await cubit.load();

      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.offer?.id, 1);
      expect(cubit.state.notFound, isFalse);
    });

    test('404 is flagged as not found', () async {
      final offers = _FakeOffers()
        ..detailsResult = const ServerFailure<OfferModel>(404, 'nf');
      final cubit = OfferDetailsCubit(offers, 9);

      await cubit.load();

      expect(cubit.state.status, ViewStatus.failure);
      expect(cubit.state.notFound, isTrue);
    });

    test('other server error is not "not found"', () async {
      final offers = _FakeOffers()
        ..detailsResult = const ServerFailure<OfferModel>(500, 'e');
      final cubit = OfferDetailsCubit(offers, 9);

      await cubit.load();

      expect(cubit.state.notFound, isFalse);
    });
  });

  test('kotlinFloatString mimics Float.toString', () {
    expect(kotlinFloatString(220), '220.0');
    expect(kotlinFloatString(138.5), '138.5');
    expect(kotlinFloatString(null), 'null');
  });
}
