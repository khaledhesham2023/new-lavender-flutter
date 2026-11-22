import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/core/enums/enums.dart';
import 'package:lavender/data/models/responses/report.dart';
import 'package:lavender/data/repositories/profile_repository.dart';
import 'package:lavender/features/reports/my_reports_cubit.dart';

class _FakeProfile implements ProfileRepository {
  final Map<ReportType, Completer<ApiResult<List<DayReportsModel>>>> pending =
      {};
  final List<ReportType> asked = [];
  ApiResult<List<DayReportsModel>>? immediate;

  @override
  Future<ApiResult<List<DayReportsModel>>> getReports(ReportType type) {
    asked.add(type);
    final now = immediate;
    if (now != null) return Future.value(now);
    return (pending[type] = Completer()).future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _day = DayReportsModel(
  date: '1 Jan',
  reports: [ReportModel(id: 1, title: 'CT', file: 'https://x/ct.pdf')],
);

void main() {
  test('loads radiology first', () async {
    final repo = _FakeProfile()..immediate = const ApiSuccess([_day]);
    final cubit = MyReportsCubit(repo);
    await cubit.load();
    expect(repo.asked, [ReportType.radiology]);
    expect(cubit.state.status, ViewStatus.success);
    expect(cubit.state.days, [_day]);
    expect(cubit.state.isEmpty, isFalse);
  });

  test('an empty answer is the empty view', () async {
    final repo = _FakeProfile()..immediate = const ApiSuccess([]);
    final cubit = MyReportsCubit(repo);
    await cubit.load();
    expect(cubit.state.status, ViewStatus.success);
    expect(cubit.state.isEmpty, isTrue);
  });

  test('select refetches for the new type; the same type does not', () async {
    final repo = _FakeProfile()..immediate = const ApiSuccess([_day]);
    final cubit = MyReportsCubit(repo);
    await cubit.load();
    cubit.select(ReportType.radiology);
    expect(repo.asked, [ReportType.radiology]);
    cubit.select(ReportType.laboratory);
    await cubit.stream.firstWhere((s) => s.status == ViewStatus.success);
    expect(repo.asked, [ReportType.radiology, ReportType.laboratory]);
    expect(cubit.state.type, ReportType.laboratory);
  });

  test('a late answer for the previous type is ignored', () async {
    final repo = _FakeProfile();
    final cubit = MyReportsCubit(repo);
    final first = cubit.load(); // radiology, still pending
    cubit.select(ReportType.laboratory);
    repo.pending[ReportType.laboratory]!.complete(const ApiSuccess([_day]));
    await cubit.stream.firstWhere((s) => s.status == ViewStatus.success);
    repo.pending[ReportType.radiology]!.complete(const ApiSuccess([]));
    await first;
    expect(cubit.state.type, ReportType.laboratory);
    expect(cubit.state.days, [_day]);
  });

  test('a failure is kept for the screen', () async {
    final repo = _FakeProfile()..immediate = const NetworkFailure();
    final cubit = MyReportsCubit(repo);
    await cubit.load();
    expect(cubit.state.status, ViewStatus.failure);
    expect(cubit.state.failure, isA<NetworkFailure>());
  });

  test('refresh asks again for the current type', () async {
    final repo = _FakeProfile()..immediate = const ApiSuccess([_day]);
    final cubit = MyReportsCubit(repo);
    await cubit.load();
    await cubit.refresh();
    expect(repo.asked, [ReportType.radiology, ReportType.radiology]);
  });
}
