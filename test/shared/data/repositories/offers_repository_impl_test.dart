import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/responses/offer.dart';
import 'package:lavender/shared/data/repositories/offers_repository_impl.dart';

import '../../../data/repositories/fake_api.dart';

void main() {
  group('OffersRepositoryImpl', () {
    test('bySpecialty / details / myOfferDetails / session paths', () async {
      var (api, a) = await makeApi(
        body: {
          'data': [
            {'id': 1, 'name': 'o'},
          ],
        },
      );
      final list = await OffersRepositoryImpl(api).bySpecialty(6);
      expect(a.path, 'client/offers');
      expect(a.query, {'specialty_id': 6});
      expect((list as ApiSuccess<List<OfferModel>>).data.length, 1);

      (api, a) = await makeApi(
        body: {
          'data': {'id': 2},
        },
      );
      await OffersRepositoryImpl(api).details(2);
      expect(a.path, 'client/offers/2');
      await OffersRepositoryImpl(api).myOfferDetails(2);
      expect(a.path, 'client/my-offers/2');

      (api, a) = await makeApi(
        body: {
          'data': {'id': 8},
        },
      );
      final s = await OffersRepositoryImpl(api).session(8);
      expect(a.path, 'client/session/8');
      expect((s as ApiSuccess<SessionDetailsModel>).data.id, 8);
    });

    test('myOffers parses both lists', () async {
      final (api, a) = await makeApi(
        body: {
          'data': {
            'available_offers': [
              {'id': 1},
            ],
            'completed_offers': [],
          },
        },
      );
      final r = await OffersRepositoryImpl(api).myOffers();
      expect(a.path, 'client/my-offers');
      final d = (r as ApiSuccess<MyOffersData>).data;
      expect(d.availableOffers.length, 1);
      expect(d.completedOffers, isEmpty);
    });

    test('buy → POST client/offers {offer_id}', () async {
      final (api, a) = await makeApi(
        body: {
          'data': {'id': 77},
        },
      );
      final r = await OffersRepositoryImpl(api).buy(4);
      expect(a.method, 'POST');
      expect(a.path, 'client/offers');
      expect(a.data, {'offer_id': 4});
      expect((r as ApiSuccess<OfferModel>).data.id, 77);
    });
  });
}
