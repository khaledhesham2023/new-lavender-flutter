import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/responses/speciality.dart';
import 'package:lavender/shared/data/repositories/specialities_repository_impl.dart';

import '../../../data/repositories/fake_api.dart';

void main() {
  group('SpecialitiesRepositoryImpl', () {
    test('getSpecialities → GET client/specialty', () async {
      final (api, a) = await makeApi(
        body: {
          'data': [
            {'id': 1, 'name': 'Dental'},
          ],
        },
      );
      final r = await SpecialitiesRepositoryImpl(api).getSpecialities();
      expect(a.path, 'client/specialty');
      expect((r as ApiSuccess<List<SpecialityModel>>).data.single.id, 1);
    });

    test('getDoctors: 2 sub-specialties + gender, null sort', () async {
      final (api, a) = await makeApi(
        body: {
          'data': {
            'doctors': [
              {'id': 1},
            ],
            'count': 1,
          },
        },
      );
      final r = await SpecialitiesRepositoryImpl(api)
          .getDoctors(5, gender: 'male', subSpecialtyIds: [1, 2]);
      expect(a.method, 'GET');
      expect(a.path, 'client/specialty/5');
      expect(a.query, {
        'gender': 'male',
        'sub_specialty[0]': 1,
        'sub_specialty[1]': 2,
      });
      final d = (r as ApiSuccess<DoctorsBySpecialityData>).data;
      expect(d.doctors.length, 1);
      expect(d.count, 1);
    });

    test('getDoctors sends prices like Float.toString and the name', () async {
      final (api, a) = await makeApi(body: {'data': {}});
      await SpecialitiesRepositoryImpl(api).getDoctors(
        5,
        sortBy: 'price',
        minPrice: 50,
        maxPrice: 150,
        name: 'a b',
      );
      expect(a.path, 'client/specialty/5');
      expect(a.query, {
        'sort_by': 'price',
        'max_price': 150.0,
        'min_price': 50.0,
        'doctor_name': 'a b',
      });
    });
  });
}
