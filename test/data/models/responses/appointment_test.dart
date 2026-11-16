import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/data/models/responses/appointment.dart';
import 'package:lavender/data/models/requests/booking_draft.dart';
import 'package:lavender/data/models/requests/appointment_requests.dart';

void main() {
  test('AppointmentData defaults: canReschedule true, isReviewed false', () {
    final a = AppointmentData.fromJson({
      'id': '4',
      'day': 'Sunday',
      'status': 'pending',
      'date_timeStamp': '2024-05-01 10:00:00',
      'formated_date': '1 May',
      'doctor': {'id': 1, 'price': '100'},
      'offer': {'id': 2},
    });
    expect(a.id, 4);
    expect(a.canReschedule, true);
    expect(a.isReviewed, false);
    expect(a.dateTimeStamp, '2024-05-01 10:00:00');
    expect(a.formatedDate, '1 May');
    expect(a.doctor!.price, '100');
    expect(a.offer!.id, 2);
    expect(a.report, isNull);
    final b = AppointmentData.fromJson({'can_reschedule': 0, 'is_reviewed': 1});
    expect(b.canReschedule, false);
    expect(b.isReviewed, true);
  });

  test('QuickComment', () {
    final q = QuickComment.fromJson({'id': 1, 'text': 'Nice'});
    expect(q.text, 'Nice');
  });

  test('requests omit null fields', () {
    expect(const SaveAppointmentRequest(doctorId: 1, day: '2024-05-01').toJson(),
        {'doctor_id': 1, 'day': '2024-05-01'});
    expect(const SaveAppointmentRequest().toJson(), isEmpty);
    expect(const RebookRequest(day: 'd').toJson(), {'day': 'd'});
    expect(const GetBookingsRequest().toJson(), isEmpty);
    expect(const GetBookingsRequest(status: 'pending').toJson(), {'status': 'pending'});
  });

  test('AddCommentRequest rate is null when not set', () {
    expect(const AddCommentRequest(doctorId: 1, comment: 'x').toJson(),
        {'doctor_id': 1, 'comment': 'x'});
    expect(const AddCommentRequest(rate: 4.5, quickCommentId: 2).toJson(),
        {'rate': 4.5, 'quick_comment_id': 2});
  });

  test('UpdateAppointmentRequest includes _method put', () {
    expect(
      const UpdateAppointmentRequest(doctorId: 1, day: 'd', time: 't').toJson(),
      {'doctor_id': 1, 'day': 'd', 'time': 't', '_method': 'put'},
    );
  });

  test('ChangeAppointmentRequest keys', () {
    expect(
      const ChangeAppointmentRequest(
              doctorId: 1, day: 'd', dayName: 'Sun', time: 't')
          .toJson(),
      {'doctor_id': 1, 'day': 'd', 'dayName': 'Sun', 'time': 't'},
    );
  });

  test('BookingDraft copyWith', () {
    const d = BookingDraft(doctorId: 1, doctorName: 'Dr', examinationPrice: '100');
    final e = d.copyWith(time: '10:00:00', day: 'الأحد');
    expect(e.doctorId, 1);
    expect(e.time, '10:00:00');
    expect(e.day, 'الأحد');
    expect(e.examinationPrice, '100');
    expect(d.time, isNull);
    expect(d.copyWith(), d);
  });
}
