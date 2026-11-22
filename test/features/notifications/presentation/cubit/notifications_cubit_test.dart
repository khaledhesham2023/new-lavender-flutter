import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/core/storage/app_prefs.dart';
import 'package:lavender/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:lavender/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepo implements NotificationsRepository {
  ApiResult<bool> toggleResult = const ApiSuccess(true);
  ApiResult<void> readResult = const ApiSuccess(null);
  ApiResult<void> deleteResult = const ApiSuccess(null, message: 'removed');
  final List<String> read = [];
  final List<String> deleted = [];
  int toggles = 0;

  @override
  Future<ApiResult<bool>> toggleAllow() async {
    toggles++;
    return toggleResult;
  }

  @override
  Future<ApiResult<void>> markRead(String id) async {
    read.add(id);
    return readResult;
  }

  @override
  Future<ApiResult<void>> delete(String id) async {
    deleted.add(id);
    return deleteResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<(NotificationsCubit, _FakeRepo, AppPrefs)> _make({
  bool allowed = false,
}) async {
  SharedPreferences.setMockInitialValues({
    AppPrefs.keyAllowNotifications: allowed,
  });
  final prefs = AppPrefs(await SharedPreferences.getInstance());
  final repo = _FakeRepo();
  return (NotificationsCubit(repo, prefs), repo, prefs);
}

void main() {
  test('the switch starts from the stored value', () async {
    final (off, _, _) = await _make();
    expect(off.state.allowed, isFalse);
    final (on, _, _) = await _make(allowed: true);
    expect(on.state.allowed, isTrue);
  });

  test('toggle takes the server value and stores it', () async {
    final (cubit, repo, prefs) = await _make();
    await cubit.toggleAllow();
    expect(repo.toggles, 1);
    expect(cubit.state.allowed, isTrue);
    expect(cubit.state.toggling, isFalse);
    expect(prefs.allowNotifications, isTrue);
  });

  test('a failed toggle puts the switch back and reports the failure', () async {
    final (cubit, repo, prefs) = await _make(allowed: true);
    repo.toggleResult = const NetworkFailure();
    final states = <NotificationsState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.toggleAllow();
    await sub.cancel();
    // Flipped at once, then flipped back with the failure.
    expect(states.first.allowed, isFalse);
    expect(states.first.toggling, isTrue);
    expect(cubit.state.allowed, isTrue);
    expect(cubit.state.toggleFailure, isA<NetworkFailure>());
    expect(prefs.allowNotifications, isTrue);
    cubit.consumeToggleFailure();
    expect(cubit.state.toggleFailure, isNull);
    expect(cubit.state.allowed, isTrue);
  });

  test('a second toggle while one is running is ignored', () async {
    final (cubit, repo, _) = await _make();
    final first = cubit.toggleAllow();
    await cubit.toggleAllow();
    await first;
    expect(repo.toggles, 1);
  });

  test('read and delete go straight to the repository', () async {
    final (cubit, repo, _) = await _make();
    expect(await cubit.markRead('a'), isA<ApiSuccess<void>>());
    final deleted = await cubit.delete('b');
    expect((deleted as ApiSuccess).message, 'removed');
    expect(repo.read, ['a']);
    expect(repo.deleted, ['b']);
  });
}
