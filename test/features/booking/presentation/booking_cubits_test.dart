import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/requests/appointment_requests.dart';
import 'package:lavender/data/models/requests/booking_draft.dart';
import 'package:lavender/data/models/responses/appointment.dart';
import 'package:lavender/data/models/responses/doctor.dart';
import 'package:lavender/shared/domain/repositories/booking_repository.dart';
import 'package:lavender/features/booking/presentation/appointment_requested_cubit.dart';
import 'package:lavender/features/booking/presentation/book_appointment_cubit.dart';
import 'package:lavender/features/booking/presentation/change_appointment_cubit.dart';

class _FakeBookingRepository implements BookingRepository {
  ApiResult<AppointmentData> saveResult = const ApiSuccess(
    AppointmentData(id: 42),
  );
  ApiResult<AppointmentData> detailsResult = const ApiSuccess(
    AppointmentData(id: 42),
  );
  ApiResult<List<WorkTimeModel>> workTimesResult = const ApiSuccess([]);
  final List<SaveAppointmentRequest> saved = [];

  @override
  Future<ApiResult<AppointmentData>> save(SaveAppointmentRequest r) async {
    saved.add(r);
    return saveResult;
  }

  @override
  Future<ApiResult<AppointmentData>> details(int id) async => detailsResult;

  @override
  Future<ApiResult<List<WorkTimeModel>>> workTimes(int doctorId) async =>
      workTimesResult;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _draft = BookingDraft(
  doctorId: 7,
  date: '2025-03-08T00:00:00.000000Z',
  formattedDate: 'Saturday, 08 March 2025',
  day: 'Saturday',
  time: '10:00',
);

const _day = WorkTimeModel(
  dayTranslated: 'Sunday',
  date: '2025-03-09T00:00:00.000000Z',
  isActive: 1,
);
const _time = TimeModel(time: '11:30 AM', timeFormatted: '11:30');

void main() {
  setUpAll(() => initializeDateFormatting());

  group('BookAppointmentCubit', () {
    late _FakeBookingRepository repo;
    late BookAppointmentCubit cubit;

    setUp(() {
      repo = _FakeBookingRepository();
      cubit = BookAppointmentCubit(repo, _draft);
    });

    tearDown(() => cubit.close());

    test('starts with the draft date text', () {
      expect(cubit.state.dayText, 'Saturday, 08 March 2025');
    });

    test('changeTo replaces date, day, time and the day text', () {
      cubit.changeTo(
        const ChangeAppointmentRequest(
          doctorId: 7,
          day: '2025-03-09T00:00:00.000000Z',
          dayName: 'Sunday',
          time: '11:30',
        ),
        lang: 'en',
      );
      expect(cubit.state.dayText, 'Sunday,09 March 2025');
      expect(cubit.state.draft.date, '2025-03-09T00:00:00.000000Z');
      expect(cubit.state.draft.time, '11:30');
    });

    test('book sends day-only date, trimmed notes and exposes the id', () async {
      await cubit.book('  pain  ');
      expect(repo.saved.single.doctorId, 7);
      expect(repo.saved.single.day, '2025-03-08');
      expect(repo.saved.single.time, '10:00');
      expect(repo.saved.single.notes, 'pain');
      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.bookedId, 42);
      cubit.consume();
      expect(cubit.state.status, ViewStatus.initial);
      expect(cubit.state.bookedId, isNull);
    });

    test('blank notes are sent as null', () async {
      await cubit.book('   ');
      expect(repo.saved.single.notes, isNull);
    });

    test('a failure is kept for the screen', () async {
      repo.saveResult = ServerFailure(422, 'reserved');
      await cubit.book('');
      expect(cubit.state.status, ViewStatus.failure);
      expect(cubit.state.failure, isA<ServerFailure>());
      expect(cubit.state.bookedId, isNull);
    });
  });

  group('ChangeAppointmentCubit', () {
    late _FakeBookingRepository repo;
    late ChangeAppointmentCubit cubit;

    setUp(() {
      repo = _FakeBookingRepository();
      cubit = ChangeAppointmentCubit(repo, 7);
    });

    tearDown(() => cubit.close());

    test('load stores the days; failure is kept', () async {
      repo.workTimesResult = const ApiSuccess([_day]);
      await cubit.load();
      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.days, [_day]);

      repo.workTimesResult = NetworkFailure();
      await cubit.load();
      expect(cubit.state.status, ViewStatus.failure);
      expect(cubit.state.failure, isA<NetworkFailure>());
    });

    test('confirm asks for the day, then the time', () {
      expect(cubit.confirm(), isA<ChangeNeedsDay>());
      cubit.selectDay(_day);
      expect(cubit.confirm(), isA<ChangeNeedsTime>());
    });

    test('confirm builds the request; another day clears the time', () {
      cubit.selectDay(_day);
      cubit.selectTime(_time);
      final result = cubit.confirm() as ChangeConfirmed;
      expect(result.request.doctorId, 7);
      expect(result.request.day, '2025-03-09T00:00:00.000000Z');
      expect(result.request.dayName, 'Sunday');
      expect(result.request.time, '11:30');

      cubit.selectDay(_day);
      expect(cubit.state.selectedTime, isNull);
    });
  });

  group('AppointmentRequestedCubit', () {
    test('load success and failure', () async {
      final repo = _FakeBookingRepository();
      final cubit = AppointmentRequestedCubit(repo, 42);
      await cubit.load();
      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.appointment?.id, 42);

      repo.detailsResult = ServerFailure(500, 'x');
      await cubit.load();
      expect(cubit.state.status, ViewStatus.failure);
      await cubit.close();
    });
  });
}
