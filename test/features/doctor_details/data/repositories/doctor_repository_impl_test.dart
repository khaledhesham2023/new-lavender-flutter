import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/responses/doctor.dart';
import 'package:lavender/features/doctor_details/data/repositories/doctor_repository_impl.dart';

import '../../../../data/repositories/fake_api.dart';

void main() {
  group('DoctorRepositoryImpl', () {
    test('getDoctor parses a full doctor', () async {
      final (api, a) = await makeApi(
        body: {
          'data': {
            'id': 3,
            'name': 'Dr B',
            'price': 120,
            'is_fav': 0,
            'work_times': [
              {
                'day': 'sat',
                'is_active': 1,
                'times': [
                  {'time': '10:00', 'is_reserved': 0},
                ],
              },
            ],
            'reviews': [
              {'id': 1, 'rate': '4.5', 'comment': 'good'},
            ],
          },
        },
      );
      final r = await DoctorRepositoryImpl(api).getDoctor(3);
      expect(a.method, 'GET');
      expect(a.path, 'general/doctor/3');
      final d = (r as ApiSuccess<DoctorModel>).data;
      expect(d.name, 'Dr B');
      expect(d.price, '120');
      expect(d.workTimes.single.times.single.time, '10:00');
      expect(d.reviews.single.rate, 4.5);
    });

    test('toggleFavorite doctor_id is a string', () async {
      final (api, a) = await makeApi();
      await DoctorRepositoryImpl(api).toggleFavorite(3);
      expect(a.method, 'POST');
      expect(a.path, 'client/fav');
      expect(a.data, {'doctor_id': '3'});
    });
  });
}
