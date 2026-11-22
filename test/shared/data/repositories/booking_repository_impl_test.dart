import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/requests/appointment_requests.dart';
import 'package:lavender/data/models/responses/appointment.dart';
import 'package:lavender/data/models/responses/doctor.dart';
import 'package:lavender/shared/data/repositories/booking_repository_impl.dart';

import '../../../data/repositories/fake_api.dart';

void main() {
  group('BookingRepositoryImpl', () {
    const appt = {
      'data': {'id': 12, 'status': 'pending'},
    };

    test('save → POST client/appointments', () async {
      final (api, a) = await makeApi(body: appt);
      final r = await BookingRepositoryImpl(api).save(
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
      final r = await BookingRepositoryImpl(api).list(status: 'upcoming');
      expect(a.method, 'GET');
      expect(a.path, 'client/appointments');
      expect(a.query, {'status': 'upcoming'});
      expect((r as ApiSuccess<List<AppointmentData>>).data.length, 1);

      (api, a) = await makeApi(body: {'data': []});
      await BookingRepositoryImpl(api)
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
      await BookingRepositoryImpl(api).details(12);
      expect(a.method, 'GET');
      expect(a.path, 'client/appointments/12');
    });

    test('cancel has no body', () async {
      final (api, a) = await makeApi();
      final r = await BookingRepositoryImpl(api).cancel(12);
      expect(a.method, 'POST');
      expect(a.path, 'client/appointments/12');
      expect(a.data, isNull);
      expect(r, isA<ApiSuccess<void>>());
    });

    test('update body has _method put', () async {
      final (api, a) = await makeApi();
      await BookingRepositoryImpl(api).update(
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
      final r = await BookingRepositoryImpl(api)
          .rebook(12, const RebookRequest(day: '2026-02-01', time: '9:00 AM'));
      expect(a.path, 'client/appointments/recreate/12');
      expect(a.data, {'day': '2026-02-01', 'time': '9:00 AM'});
      expect((r as ApiSuccess<AppointmentData>).data.id, 12);
    });

    test('addComment returns the message', () async {
      final (api, a) = await makeApi(body: {'data': null, 'message': 'thanks'});
      final r = await BookingRepositoryImpl(api).addComment(
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
      final r = await BookingRepositoryImpl(api).quickComments();
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
      final ok = await BookingRepositoryImpl(api).workTimes(3);
      expect(a.path, 'general/work-times/3');
      expect((ok as ApiSuccess<List<WorkTimeModel>>).data.length, 1);

      (api, a) = await makeApi(body: {'message': 'no times'}, status: 404);
      final r = await BookingRepositoryImpl(api).workTimes(3);
      expect(r, isA<ServerFailure<List<WorkTimeModel>>>());
      expect((r as ServerFailure).code, 404);
      expect((r as ServerFailure).message, 'no times');
    });
  });
}
