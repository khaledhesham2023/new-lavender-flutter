import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/core/enums/enums.dart';
import 'package:lavender/data/models/responses/appointment.dart';
import 'package:lavender/shared/domain/repositories/booking_repository.dart';
import 'package:lavender/features/bookings/presentation/bookings_cubit.dart';
import 'package:lavender/features/bookings/presentation/bookings_state.dart';

class _Call {
  final String status;
  final String? month;
  final String? keyword;
  final String? type;

  _Call(this.status, this.month, this.keyword, this.type);
}

class _FakeBookingRepository implements BookingRepository {
  ApiResult<List<AppointmentData>> result = const ApiSuccess([
    AppointmentData(id: 1),
    AppointmentData(id: 2),
  ]);
  final List<_Call> calls = [];

  /// When set, the next call waits for it.
  Completer<ApiResult<List<AppointmentData>>>? gate;

  @override
  Future<ApiResult<List<AppointmentData>>> list({
    required String status,
    String? month,
    String? keyword,
    String? type,
  }) {
    calls.add(_Call(status, month, keyword, type));
    final g = gate;
    if (g != null) {
      gate = null;
      return g.future;
    }
    return Future.value(result);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeBookingRepository repo;
  late BookingsCubit cubit;

  setUp(() {
    repo = _FakeBookingRepository();
    cubit = BookingsCubit(repo);
  });

  tearDown(() => cubit.close());

  test('starts on the pending tab with no filters', () {
    expect(cubit.state.status, BookingStatus.pending);
    expect(cubit.state.month, isNull);
    expect(cubit.state.type, isNull);
    expect(cubit.state.keyword, isNull);
    expect(cubit.state.viewStatus, ViewStatus.initial);
  });

  test('load sends the current status and clears items while loading',
      () async {
    await cubit.load();
    expect(cubit.state.items.map((e) => e.id), [1, 2]);

    final states = <BookingsState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.load();
    await Future<void>.delayed(Duration.zero); // let the stream deliver
    await sub.cancel();

    expect(states.first.viewStatus, ViewStatus.loading);
    expect(states.first.items, isEmpty);
    expect(states.last.viewStatus, ViewStatus.success);
    expect(repo.calls.last.status, 'pending');
    expect(repo.calls.last.month, isNull);
    expect(repo.calls.last.keyword, isNull);
    expect(repo.calls.last.type, isNull);
  });

  test('selectTab loads that status, in the Android tab order', () async {
    for (final status in BookingStatus.values.skip(1)) {
      await cubit.selectTab(status);
      expect(repo.calls.last.status, status.value);
      expect(cubit.state.status, status);
    }
    expect(BookingStatus.values.map((s) => s.position), [0, 1, 2, 3, 4, 5]);
  });

  test('re-selecting the current tab does not reload', () async {
    await cubit.selectTab(BookingStatus.pending);
    expect(repo.calls, isEmpty);
  });

  test('setMonth and setType are passed to the repository', () async {
    await cubit.setMonth('6');
    expect(repo.calls.last.month, '6');
    await cubit.setType('offer');
    expect(repo.calls.last.month, '6');
    expect(repo.calls.last.type, 'offer');
    await cubit.setMonth(null);
    expect(repo.calls.last.month, isNull);
    expect(repo.calls.last.type, 'offer');
  });

  test('setKeyword trims; blank becomes null', () async {
    await cubit.setKeyword('  dr ali ');
    expect(repo.calls.last.keyword, 'dr ali');
    expect(cubit.state.keyword, 'dr ali');

    await cubit.setKeyword('   ');
    expect(repo.calls.last.keyword, isNull);
    expect(cubit.state.keyword, isNull);

    await cubit.setKeyword(null);
    expect(repo.calls.last.keyword, isNull);
  });

  test('keyword and filters survive a tab change', () async {
    await cubit.setKeyword('x');
    await cubit.setMonth('3');
    await cubit.setType('not_offer');
    await cubit.selectTab(BookingStatus.completed);
    final call = repo.calls.last;
    expect(call.status, 'completed');
    expect(call.keyword, 'x');
    expect(call.month, '3');
    expect(call.type, 'not_offer');
  });

  group('red dots', () {
    test('date dot shows while a month is set', () async {
      expect(cubit.state.hasDateFilter, isFalse);
      await cubit.setMonth('12');
      expect(cubit.state.hasDateFilter, isTrue);
      await cubit.setMonth(null);
      expect(cubit.state.hasDateFilter, isFalse);
    });

    test('type dot hides for null and "default"', () async {
      expect(cubit.state.hasTypeFilter, isFalse);
      await cubit.setType('default');
      expect(cubit.state.hasTypeFilter, isFalse);
      await cubit.setType('offer');
      expect(cubit.state.hasTypeFilter, isTrue);
      await cubit.setType('not_offer');
      expect(cubit.state.hasTypeFilter, isTrue);
      await cubit.setType(null);
      expect(cubit.state.hasTypeFilter, isFalse);
    });
  });

  test('failures are kept and the list is empty', () async {
    repo.result = const ServerFailure(500, 'boom');
    await cubit.load();
    expect(cubit.state.viewStatus, ViewStatus.failure);
    expect(cubit.state.failure, isA<ServerFailure<dynamic>>());
    expect(cubit.state.items, isEmpty);

    repo.result = const ApiSuccess([AppointmentData(id: 9)]);
    await cubit.load();
    expect(cubit.state.viewStatus, ViewStatus.success);
    expect(cubit.state.failure, isNull);
  });

  test('an old response does not overwrite a newer one', () async {
    final slow = Completer<ApiResult<List<AppointmentData>>>();
    repo.gate = slow;
    final first = cubit.load(); // waits on [slow]
    repo.result = const ApiSuccess([AppointmentData(id: 7)]);
    await cubit.selectTab(BookingStatus.confirmed); // newer, answers at once
    slow.complete(const ApiSuccess([AppointmentData(id: 1)]));
    await first;
    expect(cubit.state.items.map((e) => e.id), [7]);
  });

  test('removeAt drops one item; reload refetches', () async {
    await cubit.load();
    cubit.removeAt(0);
    expect(cubit.state.items.map((e) => e.id), [2]);
    cubit.removeAt(5); // out of range: ignored
    expect(cubit.state.items.map((e) => e.id), [2]);

    final before = repo.calls.length;
    await cubit.reload();
    expect(repo.calls.length, before + 1);
    expect(cubit.state.items.map((e) => e.id), [1, 2]);
  });
}
