import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/responses/search.dart';
import 'package:lavender/data/models/responses/speciality.dart';
import 'package:lavender/shared/data/repositories/search_repository_impl.dart';

import '../../../data/repositories/fake_api.dart';

void main() {
  group('SearchRepositoryImpl', () {
    test('mostSelected / recent / clearRecent', () async {
      var (api, a) = await makeApi(
        body: {
          'data': [
            {'id': 1, 'name': 'Dental'},
          ],
        },
      );
      final most = await SearchRepositoryImpl(api).mostSelected();
      expect(a.method, 'GET');
      expect(a.path, 'client/search/most');
      expect((most as ApiSuccess<List<SpecialityModel>>).data.length, 1);

      (api, a) = await makeApi(
        body: {
          'data': [
            {'id': 2, 'search': 'eye'},
          ],
        },
      );
      final recent = await SearchRepositoryImpl(api).recent();
      expect(a.method, 'GET');
      expect(a.path, 'client/search');
      expect((recent as ApiSuccess<List<RecentSearchModel>>).data.single.id, 2);

      (api, a) = await makeApi();
      await SearchRepositoryImpl(api).clearRecent();
      expect(a.method, 'DELETE');
      expect(a.path, 'client/search/clear');
    });

    test('search sends the keyword in the query, no body', () async {
      final (api, a) = await makeApi(
        body: {
          'data': {'doctors': [], 'specialties': []},
        },
      );
      final r = await SearchRepositoryImpl(api).search('eye');
      expect(a.method, 'POST');
      expect(a.path, 'client/search');
      expect(a.query, {'keyword': 'eye'});
      expect(a.data, isNull);
      expect(r, isA<ApiSuccess<SearchResultsData>>());
    });

    test('filterDetails → GET general/filter-details/{id}', () async {
      final (api, a) = await makeApi(
        body: {
          'data': {
            'specialties': [
              {'id': 1, 'name': 'x'},
            ],
            'max_price': '200',
            'min_price': 10,
          },
        },
      );
      final r = await SearchRepositoryImpl(api).filterDetails(4);
      expect(a.path, 'general/filter-details/4');
      final d = (r as ApiSuccess<FilterData>).data;
      expect(d.maxPrice, 200);
      expect(d.minPrice, 10);
      expect(d.specialties.length, 1);
    });
  });
}
