import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/core/utils/file_downloader.dart';
import 'package:lavender/data/models/responses/appointment.dart';
import 'package:lavender/shared/domain/repositories/booking_repository.dart';
import 'package:lavender/features/appointment_details/presentation/appointment_details_cubit.dart';

class _FakeRepo implements BookingRepository {
  ApiResult<AppointmentData> result = const ApiSuccess(AppointmentData(id: 5));
  int calls = 0;

  @override
  Future<ApiResult<AppointmentData>> details(int id) async {
    calls++;
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('load emits success with the appointment', () async {
    final repo = _FakeRepo();
    final cubit = AppointmentDetailsCubit(repo, 5);
    await cubit.load();
    expect(cubit.state.status, ViewStatus.success);
    expect(cubit.state.appointment?.id, 5);
  });

  test('load keeps the 404 failure and reload refetches', () async {
    final repo = _FakeRepo()..result = const ServerFailure(404, 'nf');
    final cubit = AppointmentDetailsCubit(repo, 5);
    await cubit.load();
    expect(cubit.state.status, ViewStatus.failure);
    expect((cubit.state.failure as ServerFailure).code, 404);
    repo.result = const ApiSuccess(AppointmentData(id: 5));
    await cubit.reload();
    expect(repo.calls, 2);
    expect(cubit.state.status, ViewStatus.success);
  });

  test('downloadFileName uses the last segment or <title>.pdf', () {
    expect(downloadFileName('https://x.com/a/report.pdf', 'T'), 'report.pdf');
    expect(downloadFileName('https://x.com/a/12', 'Medical Report'), 'Medical Report.pdf');
    expect(downloadFileName('https://x.com/', 'A/B'), 'A_B.pdf');
  });
}
