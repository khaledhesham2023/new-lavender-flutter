import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/core/enums/enums.dart';
import 'package:lavender/data/models/requests/appointment_requests.dart';
import 'package:lavender/data/models/responses/appointment.dart';
import 'package:lavender/data/models/responses/doctor.dart';
import 'package:lavender/shared/domain/repositories/booking_repository.dart';
import 'package:lavender/features/bookings/actions/add_comment_cubit.dart';
import 'package:lavender/features/bookings/actions/confirmation_cubit.dart';
import 'package:lavender/features/bookings/actions/rebook_cubit.dart';

class _FakeRepo implements BookingRepository {
  ApiResult<void> cancelResult = const ApiSuccess(null);
  ApiResult<void> updateResult = const ApiSuccess(null);
  ApiResult<AppointmentData> rebookResult = const ApiSuccess(
    AppointmentData(id: 99),
  );
  ApiResult<String> commentResult = const ApiSuccess('thanks');

  final List<int> cancelled = [];
  final List<UpdateAppointmentRequest> updates = [];
  final List<RebookRequest> rebooks = [];
  final List<AddCommentRequest> comments = [];

  @override
  Future<ApiResult<void>> cancel(int id) async {
    cancelled.add(id);
    return cancelResult;
  }

  @override
  Future<ApiResult<void>> update(
    int id,
    UpdateAppointmentRequest request,
  ) async {
    updates.add(request);
    return updateResult;
  }

  @override
  Future<ApiResult<AppointmentData>> rebook(
    int id,
    RebookRequest request,
  ) async {
    rebooks.add(request);
    return rebookResult;
  }

  @override
  Future<ApiResult<String>> addComment(AddCommentRequest request) async {
    comments.add(request);
    return commentResult;
  }

  @override
  Future<ApiResult<List<QuickComment>>> quickComments() async =>
      const ApiSuccess([QuickComment(id: 1, text: 'great')]);

  @override
  Future<ApiResult<List<WorkTimeModel>>> workTimes(int doctorId) async =>
      const ApiSuccess([
        WorkTimeModel(
          date: '2026-12-01T00:00:00.000000Z',
          isActive: 1,
          times: [TimeModel(timeFormatted: '10:00')],
        ),
      ]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _update = UpdateAppointmentRequest(
  doctorId: 5,
  day: '2026-12-01',
  time: '10:00',
);

void main() {
  setUpAll(() => initializeDateFormatting());

  group('ConfirmationCubit', () {
    test('cancel success emits done', () async {
      final repo = _FakeRepo();
      final cubit = ConfirmationCubit(repo, const CancelAction(7));
      await cubit.confirm();
      expect(repo.cancelled, [7]);
      expect(cubit.state.done, isTrue);
      expect(cubit.state.failure, isNull);
    });

    test('update failure keeps the sheet open with the failure', () async {
      final repo = _FakeRepo()
        ..updateResult = const ServerFailure(422, 'nope');
      final cubit = ConfirmationCubit(repo, const UpdateAction(7, _update));
      await cubit.confirm();
      expect(repo.updates, [_update]);
      expect(cubit.state.done, isFalse);
      expect(cubit.state.loading, isFalse);
      expect(cubit.state.failure, isA<ServerFailure<dynamic>>());
    });
  });

  group('RebookCubit', () {
    RebookCubit make(_FakeRepo repo, BookingStatus status) => RebookCubit(
      repo,
      RebookArgs(
        appointmentId: 1,
        doctorId: 5,
        status: status,
        type: status == BookingStatus.pending ? 'book' : 'rebook',
        forOffer: true,
      ),
    );

    Future<RebookCubit> selected(_FakeRepo repo, BookingStatus status) async {
      final cubit = make(repo, status);
      await cubit.load();
      cubit.selectDay(cubit.state.days.first);
      cubit.selectTime(cubit.state.days.first.times.first);
      return cubit;
    }

    test('needs a day, then a time', () async {
      final repo = _FakeRepo();
      final cubit = make(repo, BookingStatus.pending);
      await cubit.load();
      expect(await cubit.confirm(), isA<RebookNeedsDay>());
      cubit.selectDay(cubit.state.days.first);
      expect(await cubit.confirm(), isA<RebookNeedsTime>());
    });

    test('pending returns ChangeRequested without calling the API', () async {
      final repo = _FakeRepo();
      final cubit = await selected(repo, BookingStatus.pending);
      final result = await cubit.confirm();
      expect(result, isA<RebookDone>());
      final outcome = (result as RebookDone).outcome as ChangeRequested;
      expect(outcome.request, _update);
      expect(repo.rebooks, isEmpty);
    });

    test('completed calls rebook and returns Rebooked', () async {
      final repo = _FakeRepo();
      final cubit = await selected(repo, BookingStatus.completed);
      final result = await cubit.confirm();
      final outcome = (result as RebookDone).outcome as Rebooked;
      expect(outcome.newId, 99);
      expect(outcome.forOffer, isTrue);
      expect(repo.rebooks, [const RebookRequest(day: '2026-12-01', time: '10:00')]);
    });

    test('rebook failure is reported', () async {
      final repo = _FakeRepo()..rebookResult = const NetworkFailure();
      final cubit = await selected(repo, BookingStatus.canceled);
      expect(await cubit.confirm(), isA<RebookFailed>());
      expect(cubit.state.submitting, isFalse);
    });
  });

  group('AddCommentCubit', () {
    test('0 stars sends rate null and trims the comment', () async {
      final repo = _FakeRepo();
      final cubit = AddCommentCubit(repo, doctorId: 5, appointmentId: 1);
      await cubit.send('  hi  ');
      expect(repo.comments.single.rate, isNull);
      expect(repo.comments.single.comment, 'hi');
      expect(repo.comments.single.doctorId, 5);
      expect(repo.comments.single.clientAppointmentId, 1);
      expect(cubit.state.sentMessage, 'thanks');
    });

    test('sends the chosen rate', () async {
      final repo = _FakeRepo();
      final cubit = AddCommentCubit(repo, doctorId: 5, appointmentId: 1)
        ..setRate(4);
      await cubit.send('x');
      expect(repo.comments.single.rate, 4);
    });

    test('loads quick comments', () async {
      final cubit = AddCommentCubit(_FakeRepo(), doctorId: 5, appointmentId: 1);
      await cubit.loadQuickComments();
      expect(cubit.state.quickComments.single.text, 'great');
    });
  });
}
