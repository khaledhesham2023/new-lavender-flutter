import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/core/storage/app_prefs.dart';
import 'package:lavender/data/models/responses/doctor.dart';
import 'package:lavender/data/models/responses/home.dart';
import 'package:lavender/data/models/responses/setting.dart';
import 'package:lavender/data/models/responses/speciality.dart';
import 'package:lavender/data/repositories/general_repository.dart';
import 'package:lavender/data/repositories/home_repository.dart';
import 'package:lavender/features/home/home_cubit.dart';
import 'package:lavender/features/home/widgets/greeting_header.dart';
import 'package:lavender/features/home/widgets/next_reservation_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeHomeRepository implements HomeRepository {
  ApiResult<HomeData> homeResult = const ApiSuccess(HomeData());
  ApiResult<void> favoriteResult = const ApiSuccess(null);
  final List<int> favoriteCalls = [];

  @override
  Future<ApiResult<HomeData>> getHome() async => homeResult;

  @override
  Future<ApiResult<void>> toggleFavorite(int doctorId) async {
    favoriteCalls.add(doctorId);
    return favoriteResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGeneralRepository implements GeneralRepository {
  ApiResult<SettingModel> settingsResult = const ApiSuccess(
    SettingModel(allowNotification: true, whatsAppNumber: '966500000000'),
  );

  @override
  Future<ApiResult<SettingModel>> getSettings() async => settingsResult;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<SpecialityModel> _specialities(int n) => [
  for (var i = 1; i <= n; i++) SpecialityModel(id: i, name: 'S$i'),
];

Future<(HomeCubit, _FakeHomeRepository, _FakeGeneralRepository, AppPrefs)>
_make() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = AppPrefs(await SharedPreferences.getInstance());
  final home = _FakeHomeRepository();
  final general = _FakeGeneralRepository();
  return (HomeCubit(home, general, prefs), home, general, prefs);
}

void main() {
  group('buildHomeSpecialities', () {
    test('starts with the offers tile (id 0)', () {
      final list = buildHomeSpecialities(_specialities(3), 'Offers');
      expect(list.first.id, 0);
      expect(list.first.name, 'Offers');
      expect(list.map((s) => s.id), [0, 1, 2, 3]);
    });

    test('keeps only 7 specialities when there are 8 or more', () {
      final list = buildHomeSpecialities(_specialities(12), 'Offers');
      expect(list.length, 8);
      expect(list.map((s) => s.id), [0, 1, 2, 3, 4, 5, 6, 7]);
    });

    test('exactly 8 specialities are cut to 7', () {
      final list = buildHomeSpecialities(_specialities(8), 'Offers');
      expect(list.length, 8);
      expect(list.last.id, 7);
    });

    test('empty list gives just the offers tile', () {
      expect(buildHomeSpecialities(const [], 'Offers').length, 1);
    });
  });

  group('load', () {
    test('success stores data, doctors and the settings', () async {
      final (cubit, home, _, prefs) = await _make();
      home.homeResult = const ApiSuccess(
        HomeData(
          userName: 'Sara Ali',
          doctors: [DoctorModel(id: 1, name: 'Dr A')],
        ),
      );

      await cubit.load();

      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.data?.userName, 'Sara Ali');
      expect(cubit.state.doctors.single.id, 1);
      expect(prefs.allowNotifications, isTrue);
      expect(prefs.whatsAppNumber, '966500000000');
    });

    test('home failure is exposed and settings are still saved', () async {
      final (cubit, home, _, prefs) = await _make();
      home.homeResult = const NetworkFailure();

      await cubit.load();

      expect(cubit.state.status, ViewStatus.failure);
      expect(cubit.state.failure, isA<NetworkFailure<dynamic>>());
      expect(prefs.whatsAppNumber, '966500000000');
    });

    test('a settings failure is ignored', () async {
      final (cubit, _, general, prefs) = await _make();
      general.settingsResult = const ServerFailure(500, 'x');

      await cubit.load();

      expect(cubit.state.status, ViewStatus.success);
      expect(prefs.allowNotifications, isFalse);
      expect(prefs.whatsAppNumber, '');
    });
  });

  group('toggleFavorite', () {
    Future<(HomeCubit, _FakeHomeRepository)> loaded() async {
      final (cubit, home, _, _) = await _make();
      home.homeResult = const ApiSuccess(
        HomeData(
          doctors: [
            DoctorModel(id: 1, isFav: false),
            DoctorModel(id: 2, isFav: true),
          ],
        ),
      );
      await cubit.load();
      return (cubit, home);
    }

    test('flips the heart and calls the API', () async {
      final (cubit, home) = await loaded();

      final future = cubit.toggleFavorite(0);
      // Optimistic: flipped before the API answers.
      expect(cubit.state.doctors[0].isFav, isTrue);
      await future;

      expect(cubit.state.doctors[0].isFav, isTrue);
      expect(cubit.state.doctors[1].isFav, isTrue);
      expect(home.favoriteCalls, [1]);
      expect(cubit.state.favoriteFailure, isNull);
    });

    test('reverts and exposes the failure when the call fails', () async {
      final (cubit, home) = await loaded();
      home.favoriteResult = const NetworkFailure();

      await cubit.toggleFavorite(1);

      expect(cubit.state.doctors[1].isFav, isTrue);
      expect(cubit.state.favoriteFailure, isA<NetworkFailure<dynamic>>());

      cubit.consumeFavoriteFailure();
      expect(cubit.state.favoriteFailure, isNull);
    });

    test('ignores an out-of-range index', () async {
      final (cubit, home) = await loaded();

      await cubit.toggleFavorite(5);

      expect(home.favoriteCalls, isEmpty);
    });
  });

  group('helpers', () {
    test('countdownParts splits seconds into hours and minutes', () {
      expect(countdownParts(3 * 3600 + 25 * 60 + 59), (hours: 3, minutes: 25));
      expect(countdownParts(59), (hours: 0, minutes: 0));
      expect(countdownParts(90000), (hours: 25, minutes: 0));
    });

    test('notificationBadgeText', () {
      expect(notificationBadgeText(null), isNull);
      expect(notificationBadgeText(0), isNull);
      expect(notificationBadgeText(7), '7');
      expect(notificationBadgeText(99), '99');
      expect(notificationBadgeText(100), '+99');
    });
  });
}
