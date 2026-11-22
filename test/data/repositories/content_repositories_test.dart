import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/requests/appointment_requests.dart';
import 'package:lavender/data/models/responses/appointment.dart';
import 'package:lavender/data/models/responses/doctor.dart';
import 'package:lavender/data/models/responses/home.dart';
import 'package:lavender/data/models/responses/offer.dart';
import 'package:lavender/data/models/responses/search.dart';
import 'package:lavender/data/models/responses/speciality.dart';
import 'package:lavender/data/repositories/booking_repository.dart';
import 'package:lavender/data/repositories/doctor_repository.dart';
import 'package:lavender/data/repositories/home_repository.dart';
import 'package:lavender/data/repositories/offers_repository.dart';
import 'package:lavender/data/repositories/search_repository.dart';
import 'package:lavender/data/repositories/specialities_repository.dart';

import 'fake_api.dart';

void main() {
  group('HomeRepository', () {
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
      final r = await HomeRepository(api).getHome();
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
      final r = await HomeRepository(api).toggleFavorite(7);
      expect(a.method, 'POST');
      expect(a.path, 'client/fav');
      expect(a.data, {'doctor_id': '7'});
      expect(r, isA<ApiSuccess<void>>());
    });
  });

  group('SpecialitiesRepository', () {
    test('getSpecialities → GET client/specialty', () async {
      final (api, a) = await makeApi(
        body: {
          'data': [
            {'id': 1, 'name': 'Dental'},
          ],
        },
      );
      final r = await SpecialitiesRepository(api).getSpecialities();
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
      final r = await SpecialitiesRepository(api)
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
      await SpecialitiesRepository(api).getDoctors(
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

  group('SearchRepository', () {
    test('mostSelected / recent / clearRecent', () async {
      var (api, a) = await makeApi(
        body: {
          'data': [
            {'id': 1, 'name': 'Dental'},
          ],
        },
      );
      final most = await SearchRepository(api).mostSelected();
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
      final recent = await SearchRepository(api).recent();
      expect(a.method, 'GET');
      expect(a.path, 'client/search');
      expect((recent as ApiSuccess<List<RecentSearchModel>>).data.single.id, 2);

      (api, a) = await makeApi();
      await SearchRepository(api).clearRecent();
      expect(a.method, 'DELETE');
      expect(a.path, 'client/search/clear');
    });

    test('search sends the keyword in the query, no body', () async {
      final (api, a) = await makeApi(
        body: {
          'data': {'doctors': [], 'specialties': []},
        },
      );
      final r = await SearchRepository(api).search('eye');
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
      final r = await SearchRepository(api).filterDetails(4);
      expect(a.path, 'general/filter-details/4');
      final d = (r as ApiSuccess<FilterData>).data;
      expect(d.maxPrice, 200);
      expect(d.minPrice, 10);
      expect(d.specialties.length, 1);
    });
  });

  group('DoctorRepository', () {
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
      final r = await DoctorRepository(api).getDoctor(3);
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
      await DoctorRepository(api).toggleFavorite(3);
      expect(a.method, 'POST');
      expect(a.path, 'client/fav');
      expect(a.data, {'doctor_id': '3'});
    });
  });

  group('OffersRepository', () {
    test('bySpecialty / details / myOfferDetails / session paths', () async {
      var (api, a) = await makeApi(
        body: {
          'data': [
            {'id': 1, 'name': 'o'},
          ],
        },
      );
      final list = await OffersRepository(api).bySpecialty(6);
      expect(a.path, 'client/offers');
      expect(a.query, {'specialty_id': 6});
      expect((list as ApiSuccess<List<OfferModel>>).data.length, 1);

      (api, a) = await makeApi(
        body: {
          'data': {'id': 2},
        },
      );
      await OffersRepository(api).details(2);
      expect(a.path, 'client/offers/2');
      await OffersRepository(api).myOfferDetails(2);
      expect(a.path, 'client/my-offers/2');

      (api, a) = await makeApi(
        body: {
          'data': {'id': 8},
        },
      );
      final s = await OffersRepository(api).session(8);
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
      final r = await OffersRepository(api).myOffers();
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
      final r = await OffersRepository(api).buy(4);
      expect(a.method, 'POST');
      expect(a.path, 'client/offers');
      expect(a.data, {'offer_id': 4});
      expect((r as ApiSuccess<OfferModel>).data.id, 77);
    });
  });

  group('BookingRepository', () {
    const appt = {
      'data': {'id': 12, 'status': 'pending'},
    };

    test('save → POST client/appointments', () async {
      final (api, a) = await makeApi(body: appt);
      final r = await BookingRepository(api).save(
        const SaveAppointmentRequest(
          doctorId: 1,
          day: '2026-01-02',
          time: '10:00 AM',
        ),
      );
      expect(a.method, 'POST');
      expect(a.path, 'client/appointments');
      expect(a.data, {'doctor_id': 1, 'day': '2026-01-02', 'time': '10:00 AM'});
      expect((r as ApiSuccess<AppointmentData>).data.id, 12);
    });

    test('list drops null filters', () async {
      var (api, a) = await makeApi(
        body: {
          'data': [
            {'id': 1},
          ],
        },
      );
      final r = await BookingRepository(api).list(status: 'upcoming');
      expect(a.method, 'GET');
      expect(a.path, 'client/appointments');
      expect(a.query, {'status': 'upcoming'});
      expect((r as ApiSuccess<List<AppointmentData>>).data.length, 1);

      (api, a) = await makeApi(body: {'data': []});
      await BookingRepository(api)
          .list(status: 'done', month: '3', keyword: 'x', type: 'offer');
      expect(a.query, {
        'status': 'done',
        'month': '3',
        'keyword': 'x',
        'type': 'offer',
      });
    });

    test('details → GET client/appointments/{id}', () async {
      final (api, a) = await makeApi(body: appt);
      await BookingRepository(api).details(12);
      expect(a.method, 'GET');
      expect(a.path, 'client/appointments/12');
    });

    test('cancel has no body', () async {
      final (api, a) = await makeApi();
      final r = await BookingRepository(api).cancel(12);
      expect(a.method, 'POST');
      expect(a.path, 'client/appointments/12');
      expect(a.data, isNull);
      expect(r, isA<ApiSuccess<void>>());
    });

    test('update body has _method put', () async {
      final (api, a) = await makeApi();
      await BookingRepository(api).update(
        12,
        const UpdateAppointmentRequest(
          doctorId: 1,
          day: '2026-01-03',
          time: '11:00 AM',
        ),
      );
      expect(a.method, 'POST');
      expect(a.path, 'client/appointments/12');
      expect(a.data, {
        'doctor_id': 1,
        'day': '2026-01-03',
        'time': '11:00 AM',
        '_method': 'put',
      });
    });

    test('rebook → POST client/appointments/recreate/{id}', () async {
      final (api, a) = await makeApi(body: appt);
      final r = await BookingRepository(api)
          .rebook(12, const RebookRequest(day: '2026-02-01', time: '9:00 AM'));
      expect(a.path, 'client/appointments/recreate/12');
      expect(a.data, {'day': '2026-02-01', 'time': '9:00 AM'});
      expect((r as ApiSuccess<AppointmentData>).data.id, 12);
    });

    test('addComment returns the message', () async {
      final (api, a) = await makeApi(body: {'data': null, 'message': 'thanks'});
      final r = await BookingRepository(api).addComment(
        const AddCommentRequest(
          rate: 4,
          comment: 'ok',
          doctorId: 1,
          clientAppointmentId: 12,
        ),
      );
      expect(a.path, 'client/reviews');
      expect(a.data['comment'], 'ok');
      expect((r as ApiSuccess<String>).data, 'thanks');
    });

    test('quickComments → GET general/quick-comments', () async {
      final (api, a) = await makeApi(
        body: {
          'data': [
            {'id': 1, 'text': 'Great'},
          ],
        },
      );
      final r = await BookingRepository(api).quickComments();
      expect(a.path, 'general/quick-comments');
      expect((r as ApiSuccess<List<QuickComment>>).data.single.text, 'Great');
    });

    test('workTimes parses; 404 stays ServerFailure(404)', () async {
      var (api, a) = await makeApi(
        body: {
          'data': [
            {'day': 'sat', 'is_active': 1},
          ],
        },
      );
      final ok = await BookingRepository(api).workTimes(3);
      expect(a.path, 'general/work-times/3');
      expect((ok as ApiSuccess<List<WorkTimeModel>>).data.length, 1);

      (api, a) = await makeApi(body: {'message': 'no times'}, status: 404);
      final r = await BookingRepository(api).workTimes(3);
      expect(r, isA<ServerFailure<List<WorkTimeModel>>>());
      expect((r as ServerFailure).code, 404);
      expect((r as ServerFailure).message, 'no times');
    });
  });
}
