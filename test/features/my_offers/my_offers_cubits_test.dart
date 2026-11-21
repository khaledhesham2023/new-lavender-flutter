import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/responses/offer.dart';
import 'package:lavender/data/repositories/offers_repository.dart';
import 'package:lavender/features/my_offers/my_offer_details_cubit.dart';
import 'package:lavender/features/my_offers/my_offers_cubit.dart';

class _FakeOffersRepository implements OffersRepository {
  ApiResult<MyOffersData> myOffersResult = const ApiSuccess(
    MyOffersData(
      availableOffers: [OfferModel(id: 1, name: 'valid')],
      completedOffers: [OfferModel(id: 2, name: 'done')],
    ),
  );
  ApiResult<OfferModel> detailsResult = const ApiSuccess(OfferModel(id: 7));
  int myOffersCalls = 0;
  final List<int> detailIds = [];

  @override
  Future<ApiResult<MyOffersData>> myOffers() async {
    myOffersCalls++;
    return myOffersResult;
  }

  @override
  Future<ApiResult<OfferModel>> myOfferDetails(int id) async {
    detailIds.add(id);
    return detailsResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('MyOffersCubit', () {
    test('load shows the valid offers first', () async {
      final repo = _FakeOffersRepository();
      final cubit = MyOffersCubit(repo);
      await cubit.load();
      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.tab, MyOffersTab.valid);
      expect(cubit.state.offers.single.name, 'valid');
    });

    test('toggling refetches and shows the completed offers', () async {
      final repo = _FakeOffersRepository();
      final cubit = MyOffersCubit(repo);
      await cubit.load();
      cubit.selectTab(MyOffersTab.completed);
      await cubit.stream.firstWhere((s) => s.status == ViewStatus.success);
      expect(repo.myOffersCalls, 2);
      expect(cubit.state.offers.single.name, 'done');
    });

    test('selecting the same tab does not refetch', () async {
      final repo = _FakeOffersRepository();
      final cubit = MyOffersCubit(repo);
      await cubit.load();
      cubit.selectTab(MyOffersTab.valid);
      expect(repo.myOffersCalls, 1);
    });

    test('a failure is reported and the tab is kept', () async {
      final repo = _FakeOffersRepository()
        ..myOffersResult = const NetworkFailure();
      final cubit = MyOffersCubit(repo);
      cubit.selectTab(MyOffersTab.completed);
      await cubit.stream.firstWhere((s) => s.status == ViewStatus.failure);
      expect(cubit.state.failure, isA<NetworkFailure<dynamic>>());
      expect(cubit.state.tab, MyOffersTab.completed);
      expect(cubit.state.offers, isEmpty);
    });
  });

  group('MyOfferDetailsCubit', () {
    test('load asks for the user-offer id', () async {
      final repo = _FakeOffersRepository();
      final cubit = MyOfferDetailsCubit(repo, 7);
      await cubit.load();
      expect(repo.detailIds, [7]);
      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.offer!.id, 7);
    });

    test('a failure is reported', () async {
      final repo = _FakeOffersRepository()
        ..detailsResult = const ServerFailure(500, 'boom');
      final cubit = MyOfferDetailsCubit(repo, 7);
      await cubit.load();
      expect(cubit.state.status, ViewStatus.failure);
      expect(cubit.state.failure, isA<ServerFailure<dynamic>>());
    });
  });
}
