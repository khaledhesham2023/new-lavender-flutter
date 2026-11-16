import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/data/models/responses/offer.dart';
import 'package:lavender/data/models/requests/offer_requests.dart';

void main() {
  test('OfferModel parses string/int prices and nested lists', () {
    final o = OfferModel.fromJson({
      'id': 1,
      'name': 'Pack',
      'price': '200.00',
      'discount': 10,
      'final_price': 180,
      'number': '5',
      'used_number': 2,
      'specialty_model': {'id': 3, 'name': 'Derma'},
      'appointments': [
        {'id': 9, 'status': 'confirmed'},
      ],
    });
    expect(o.price, 200.0);
    expect(o.discount, 10.0);
    expect(o.finalPrice, 180.0);
    expect(o.number, 5);
    expect(o.usedNumber, 2);
    expect(o.specialtyModel!.id, 3);
    expect(o.appointments.single.status, 'confirmed');
    expect(o.details, isNull);
  });

  test('MyOffersData with a null list', () {
    final m = MyOffersData.fromJson({
      'available_offers': [
        {'id': 1},
      ],
      'completed_offers': null,
    });
    expect(m.availableOffers.length, 1);
    expect(m.completedOffers, isEmpty);
  });

  test('SessionDetailsModel canReschedule defaults to false', () {
    final s = SessionDetailsModel.fromJson({
      'id': 1,
      'number': 4,
      'used_number': '1',
      'doctor': {'id': 2},
    });
    expect(s.canReschedule, false);
    expect(s.isReviewed, false);
    expect(s.usedNumber, 1);
    expect(s.doctor!.id, 2);
    expect(SessionDetailsModel.fromJson({'can_reschedule': 1}).canReschedule, true);
  });

  test('BuyOfferRequest', () {
    expect(const BuyOfferRequest(offerId: 3).toJson(), {'offer_id': 3});
    expect(const BuyOfferRequest().toJson(), isEmpty);
  });
}
