import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/doctor_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/general_repository.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../data/repositories/offers_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/search_repository.dart';
import '../../data/repositories/specialities_repository.dart';
import '../network/api_client.dart';
import '../push/device_token.dart';
import '../push/push_service.dart';
import '../session/session_cubit.dart';
import '../storage/app_prefs.dart';
import '../storage/user_store.dart';

final GetIt sl = GetIt.instance;

/// Registers app-wide singletons. Call once from `main()` before `runApp`.
/// Screen Cubits are not registered here: they are created by their screens
/// with `sl<Repository>()`. Only [SessionCubit] lives app-wide.
Future<void> configureDependencies() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  final prefs = AppPrefs(sharedPrefs);
  final userStore = UserStore(sharedPrefs);

  sl
    ..registerSingleton<AppPrefs>(prefs)
    ..registerSingleton<UserStore>(userStore)
    ..registerLazySingleton(() => DeviceTokenProvider(sl<AppPrefs>()))
    ..registerLazySingleton(
      () => PushService(sl<AppPrefs>(), sl<SessionCubit>()),
    )
    ..registerLazySingleton<ApiClient>(() => ApiClient(sl<AppPrefs>()))
    ..registerLazySingleton(() => AuthRepository(sl()))
    ..registerLazySingleton(() => ProfileRepository(sl()))
    ..registerLazySingleton(() => GeneralRepository(sl()))
    ..registerLazySingleton(() => NotificationsRepository(sl()))
    ..registerLazySingleton(() => HomeRepository(sl()))
    ..registerLazySingleton(() => SpecialitiesRepository(sl()))
    ..registerLazySingleton(() => SearchRepository(sl()))
    ..registerLazySingleton(() => DoctorRepository(sl()))
    ..registerLazySingleton(() => BookingRepository(sl()))
    ..registerLazySingleton(() => FavoritesRepository(sl()))
    ..registerLazySingleton(() => OffersRepository(sl()))
    ..registerSingleton<SessionCubit>(SessionCubit(prefs, userStore));
}
