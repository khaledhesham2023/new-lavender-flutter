import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/data/models/responses/home.dart';

void main() {
  test('HomeData reads the misspelled bannars key', () {
    final h = HomeData.fromJson({
      'notifications_count': '2',
      'user_name': 'Sara',
      'bannars': [
        {
          'id': 1,
          'offer_id': '9',
          'is_active': 1,
          'start_date': '2024-01-01',
          'end_date': '2024-02-01',
          'image': 'http://x/b.png',
        },
      ],
      'specialties': [
        {'id': 1, 'name': 'A'},
      ],
      'doctors': null,
      'next_reservation': {
        'id': 5,
        'day': 'Sunday',
        'time': '10:00',
        'difference': '3600',
        'doctor': {'id': 2, 'name': 'Dr'},
      },
    });
    expect(h.notificationsCount, 2);
    expect(h.banners.single.offerId, 9);
    expect(h.banners.single.isActive, 1);
    expect(h.specialties.single.name, 'A');
    expect(h.doctors, isEmpty);
    expect(h.offers, isEmpty);
    expect(h.nextReservation!.difference, 3600);
    expect(h.nextReservation!.doctor!.name, 'Dr');
    expect(h.userImage, isNull);
  });

  test('banners under the correctly spelled key are ignored', () {
    expect(HomeData.fromJson({'banners': [{'id': 1}]}).banners, isEmpty);
  });

  test('BannerModel tolerates missing fields', () {
    final b = BannerModel.fromJson({});
    expect(b.id, 0);
    expect(b.image, '');
  });
}
