import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/responses/home.dart';
import 'package:lavender/shared/data/repositories/home_repository_impl.dart';

import '../../../data/repositories/fake_api.dart';

void main() {
  group('HomeRepositoryImpl', () {
    test('getHome → GET client/home, parses data', () async {
      final (api, a) = await makeApi(
        body: {
          'data': {
            'user_name': 'Sara',
            'notifications_count': '3',
            'specialties': [
              {'id': 1, 'name': 'Dental'},
            ],
            'doctors': [
              {'id': 9, 'name': 'Dr A', 'is_fav': 1},
            ],
          },
        },
      );
      final r = await HomeRepositoryImpl(api).getHome();
      expect(a.method, 'GET');
      expect(a.path, 'client/home');
      final d = (r as ApiSuccess<HomeData>).data;
      expect(d.userName, 'Sara');
      expect(d.notificationsCount, 3);
      expect(d.specialties.single.name, 'Dental');
      expect(d.doctors.single.isFav, isTrue);
    });

    test('toggleFavorite sends doctor_id as a string', () async {
      final (api, a) = await makeApi();
      final r = await HomeRepositoryImpl(api).toggleFavorite(7);
      expect(a.method, 'POST');
      expect(a.path, 'client/fav');
      expect(a.data, {'doctor_id': '7'});
      expect(r, isA<ApiSuccess<void>>());
    });
  });
}
