import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/responses/search.dart';
import 'package:lavender/data/models/responses/speciality.dart';
import 'package:lavender/shared/domain/repositories/search_repository.dart';
import 'package:lavender/features/search/search_cubit.dart';

class _FakeSearchRepository implements SearchRepository {
  ApiResult<List<SpecialityModel>> mostResult = const ApiSuccess([
    SpecialityModel(id: 1, name: 'Dental'),
  ]);
  ApiResult<List<RecentSearchModel>> recentResult = const ApiSuccess([
    RecentSearchModel(id: 1, search: 'ahmed'),
  ]);
  ApiResult<SearchResultsData> searchResult = const ApiSuccess(
    SearchResultsData(),
  );
  ApiResult<void> clearResult = const ApiSuccess(null);

  int mostCalls = 0;
  int recentCalls = 0;
  int clearCalls = 0;
  final List<String> searched = [];

  @override
  Future<ApiResult<List<SpecialityModel>>> mostSelected() async {
    mostCalls++;
    return mostResult;
  }

  @override
  Future<ApiResult<List<RecentSearchModel>>> recent() async {
    recentCalls++;
    return recentResult;
  }

  @override
  Future<ApiResult<SearchResultsData>> search(String keyword) async {
    searched.add(keyword);
    return searchResult;
  }

  @override
  Future<ApiResult<void>> clearRecent() async {
    clearCalls++;
    return clearResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeSearchRepository repo;

  SearchCubit cubit({bool loggedIn = true}) =>
      SearchCubit(repo, isLoggedIn: loggedIn);

  setUp(() => repo = _FakeSearchRepository());

  group('SearchCubit requests', () {
    test('showMostSelected loads the specialities', () async {
      final c = cubit();
      await c.showMostSelected();

      expect(c.state.mode, SearchMode.mostSelected);
      expect(c.state.status, ViewStatus.success);
      expect(c.state.mostSelected, hasLength(1));
    });

    test('showMostSelected failure keeps the failure', () async {
      repo.mostResult = const NetworkFailure<List<SpecialityModel>>();
      final c = cubit();
      await c.showMostSelected();

      expect(c.state.status, ViewStatus.failure);
      expect(c.state.failure, isA<NetworkFailure<dynamic>>());
    });

    test('showRecent loads the recent searches', () async {
      final c = cubit();
      await c.showRecent();

      expect(c.state.mode, SearchMode.recent);
      expect(c.state.status, ViewStatus.success);
      expect(c.state.recent.single.search, 'ahmed');
    });

    test('guest never calls recent()', () async {
      final c = cubit(loggedIn: false);
      await c.showRecent();
      c.onFocusGained('');
      c.onTextChanged('', hasFocus: true);
      await Future<void>.delayed(Duration.zero);

      expect(repo.recentCalls, 0);
      expect(repo.mostCalls, 1); // blank text -> most selected
    });

    test('search success enters results mode', () async {
      repo.searchResult = const ApiSuccess(
        SearchResultsData(specialties: [SpecialityModel(id: 2, name: 'Eye')]),
      );
      final c = cubit();
      await c.search('eye');

      expect(c.state.mode, SearchMode.results);
      expect(c.state.status, ViewStatus.success);
      expect(c.state.results.specialties, hasLength(1));
      expect(repo.searched, ['eye']);
    });

    test('clearRecent empties the list', () async {
      final c = cubit();
      await c.showRecent();
      await c.clearRecent();

      expect(repo.clearCalls, 1);
      expect(c.state.mode, SearchMode.recent);
      expect(c.state.status, ViewStatus.success);
      expect(c.state.recent, isEmpty);
    });

    test('clearRecent failure shows the failure', () async {
      repo.clearResult = const ServerFailure<void>(500, 'x');
      final c = cubit();
      await c.clearRecent();

      expect(c.state.status, ViewStatus.failure);
    });

    test('a superseded slow response is dropped', () async {
      final c = cubit();
      final first = c.showMostSelected();
      await c.showRecent(); // newer request finishes first
      await first;

      expect(c.state.mode, SearchMode.recent);
      expect(c.state.mostSelected, isEmpty);
    });
  });

  group('SearchCubit text handling', () {
    test('debounce: only the last text is searched, after 500 ms', () {
      fakeAsync((async) {
        final c = cubit();
        c.onTextChanged('a', hasFocus: true);
        async.elapse(const Duration(milliseconds: 300));
        c.onTextChanged('ab', hasFocus: true);
        async.elapse(const Duration(milliseconds: 300));
        c.onTextChanged('abc', hasFocus: true);

        async.elapse(const Duration(milliseconds: 499));
        expect(repo.searched, isEmpty);

        async.elapse(const Duration(milliseconds: 1));
        async.flushMicrotasks();
        expect(repo.searched, ['abc']);
        expect(c.state.mode, SearchMode.results);
      });
    });

    test('blank text cancels the pending search', () {
      fakeAsync((async) {
        final c = cubit();
        c.onTextChanged('abc', hasFocus: true);
        async.elapse(const Duration(milliseconds: 200));
        c.onTextChanged('  ', hasFocus: false);
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();

        expect(repo.searched, isEmpty);
        expect(repo.mostCalls, 1);
      });
    });

    test('blank + logged in + focused -> recent', () {
      fakeAsync((async) {
        final c = cubit();
        c.onTextChanged('', hasFocus: true);
        async.flushMicrotasks();

        expect(repo.recentCalls, 1);
        expect(repo.mostCalls, 0);
        expect(c.state.mode, SearchMode.recent);
      });
    });

    test('blank + logged in + not focused -> most selected', () {
      fakeAsync((async) {
        final c = cubit();
        c.onTextChanged('', hasFocus: false);
        async.flushMicrotasks();

        expect(repo.recentCalls, 0);
        expect(c.state.mode, SearchMode.mostSelected);
      });
    });

    test('blank + guest -> most selected even when focused', () {
      fakeAsync((async) {
        final c = cubit(loggedIn: false);
        c.onTextChanged('', hasFocus: true);
        async.flushMicrotasks();

        expect(repo.recentCalls, 0);
        expect(c.state.mode, SearchMode.mostSelected);
      });
    });

    test('focus gained: recent only when logged in and the field is empty', () {
      fakeAsync((async) {
        final guest = cubit(loggedIn: false)..onFocusGained('');
        final typed = cubit()..onFocusGained('abc');
        async.flushMicrotasks();
        expect(repo.recentCalls, 0);
        expect(guest.state.mode, SearchMode.mostSelected);
        expect(typed.state.mode, SearchMode.mostSelected);

        final empty = cubit()..onFocusGained('  ');
        async.flushMicrotasks();
        expect(repo.recentCalls, 1);
        expect(empty.state.mode, SearchMode.recent);
      });
    });

    test('keyboard closed with a blank field returns to most selected', () async {
      final c = cubit();
      await c.showMostSelected();
      await c.showRecent();
      c.onKeyboardClosed('');

      expect(c.state.mode, SearchMode.mostSelected);
      expect(c.state.status, ViewStatus.success);
      expect(repo.mostCalls, 1); // reused the loaded list
    });

    test('keyboard closed with text keeps results and drops the pending search', () {
      fakeAsync((async) {
        final c = cubit();
        c.onTextChanged('abc', hasFocus: true);
        c.onKeyboardClosed('abc');
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(repo.searched, isEmpty);
      });
    });
  });
}
