import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/responses/doctor.dart';
import 'package:lavender/features/favorites/data/repositories/favorites_repository_impl.dart';

import '../../../../data/repositories/fake_api.dart';

void main() {
  group('FavoritesRepositoryImpl', () {
    test('getFavorites sends doctor_name only when given', () async {
      var (api, a) = await makeApi(
        body: {
          'data': [
            {'id': 1},
          ],
        },
      );
      final r = await FavoritesRepositoryImpl(api).getFavorites();
      expect(a.path, 'client/fav');
      expect(a.query, isEmpty);
      expect((r as ApiSuccess<List<DoctorModel>>).data.length, 1);

      (api, a) = await makeApi(body: {'data': []});
      await FavoritesRepositoryImpl(api).getFavorites(name: 'Sam');
      expect(a.query, {'doctor_name': 'Sam'});
    });

    test('toggleFavorite doctor_id is a string', () async {
      final (api, a) = await makeApi();
      await FavoritesRepositoryImpl(api).toggleFavorite(11);
      expect(a.data, {'doctor_id': '11'});
    });
  });
}
