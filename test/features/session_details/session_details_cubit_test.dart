import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/responses/doctor.dart';
import 'package:lavender/data/models/responses/offer.dart';
import 'package:lavender/shared/domain/repositories/offers_repository.dart';
import 'package:lavender/features/session_details/session_details_cubit.dart';

class _FakeRepo implements OffersRepository {
  ApiResult<SessionDetailsModel> result = const ApiSuccess(
    SessionDetailsModel(id: 9),
  );
  int calls = 0;

  @override
  Future<ApiResult<SessionDetailsModel>> session(int id) async {
    calls++;
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('load emits success with the session', () async {
    final cubit = SessionDetailsCubit(_FakeRepo(), 9);
    await cubit.load();
    expect(cubit.state.status, ViewStatus.success);
    expect(cubit.state.session?.id, 9);
  });

  test('a failure is kept and reload refetches', () async {
    final repo = _FakeRepo()..result = const NetworkFailure();
    final cubit = SessionDetailsCubit(repo, 9);
    await cubit.load();
    expect(cubit.state.status, ViewStatus.failure);
    expect(cubit.state.failure, isA<NetworkFailure>());
    repo.result = const ApiSuccess(SessionDetailsModel(id: 9));
    await cubit.reload();
    expect(repo.calls, 2);
    expect(cubit.state.status, ViewStatus.success);
  });

  test('sessionToAppointment keeps the action fields and marks the offer', () {
    const session = SessionDetailsModel(
      id: 9,
      doctor: DoctorModel(id: 4),
      status: 'completed',
      isReviewed: true,
    );
    final appointment = sessionToAppointment(session);
    expect(appointment.id, 9);
    expect(appointment.doctor?.id, 4);
    expect(appointment.status, 'completed');
    expect(appointment.isReviewed, isTrue);
    expect(appointment.offer, isNotNull);
    // Unlike appointments, a session cannot be rescheduled by default.
    expect(appointment.canReschedule, isFalse);
  });
}
