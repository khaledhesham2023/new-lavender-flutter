import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/doctor_repository.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../data/repositories/general_repository.dart';
import '../../data/repositories/home_repository.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../data/repositories/offers_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/search_repository.dart';
import '../../data/repositories/specialities_repository.dart';
import '../../core/network/api_client.dart';
import '../deeplink/deep_link_service.dart';
import '../../core/push/device_token.dart';
import '../push/push_service.dart';
import '../../shared/session/session_cubit.dart';
import '../../core/storage/app_prefs.dart';
import '../../shared/session/user_store.dart';

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
    ..registerLazySingleton(
      () => DeepLinkService(sl<PushService>(), sl<SessionCubit>()),
    )
    ..registerLazySingleton<ApiClient>(() => ApiClient(sl<AppPrefs>()))
    ..registerLazySingleton(() => AuthRepository(sl()))
    ..registerLazySingleton(() => ProfileRepository(sl()))
    ..registerLazySingleton(() => GeneralRepository(sl()))
    ..registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => HomeRepository(sl()))
    ..registerLazySingleton(() => SpecialitiesRepository(sl()))
    ..registerLazySingleton(() => SearchRepository(sl()))
    ..registerLazySingleton(() => DoctorRepository(sl()))
    ..registerLazySingleton(() => BookingRepository(sl()))
    ..registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => OffersRepository(sl()))
    ..registerSingleton<SessionCubit>(SessionCubit(prefs, userStore));
}
