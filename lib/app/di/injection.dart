import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/data/repositories/auth_repository_impl.dart';
import '../../shared/domain/repositories/auth_repository.dart';
import '../../shared/data/repositories/booking_repository_impl.dart';
import '../../shared/domain/repositories/booking_repository.dart';
import '../../features/doctor_details/data/repositories/doctor_repository_impl.dart';
import '../../features/doctor_details/domain/repositories/doctor_repository.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../shared/data/repositories/general_repository_impl.dart';
import '../../shared/domain/repositories/general_repository.dart';
import '../../shared/data/repositories/home_repository_impl.dart';
import '../../shared/domain/repositories/home_repository.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../shared/data/repositories/offers_repository_impl.dart';
import '../../shared/domain/repositories/offers_repository.dart';
import '../../features/content/data/repositories/content_repository_impl.dart';
import '../../features/content/domain/repositories/content_repository.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/reports/data/repositories/reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../shared/data/repositories/search_repository_impl.dart';
import '../../shared/domain/repositories/search_repository.dart';
import '../../shared/data/repositories/specialities_repository_impl.dart';
import '../../shared/domain/repositories/specialities_repository.dart';
import '../../core/network/api_client.dart';
import '../deeplink/deep_link_service.dart';
import '../../core/push/device_token.dart';
import '../push/push_service.dart';
import '../../shared/session/session_cubit.dart';
import '../../core/storage/app_prefs.dart';
import '../../shared/session/user_store.dart';
import '../../features/purchase_offer/data/tap_payment_service.dart';
import '../../features/purchase_offer/domain/services/payment_service.dart';

final GetIt sl = GetIt.instance;


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
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()))
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl()),
    )
    ..registerLazySingleton<ContentRepository>(
      () => ContentRepositoryImpl(sl()),
    )
    ..registerLazySingleton<ReportsRepository>(
      () => ReportsRepositoryImpl(sl()),
    )
    ..registerLazySingleton<GeneralRepository>(
      () => GeneralRepositoryImpl(sl()),
    )
    ..registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepositoryImpl(sl()),
    )
    ..registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()))
    ..registerLazySingleton<SpecialitiesRepository>(
      () => SpecialitiesRepositoryImpl(sl()),
    )
    ..registerLazySingleton<SearchRepository>(() => SearchRepositoryImpl(sl()))
    ..registerLazySingleton<DoctorRepository>(() => DoctorRepositoryImpl(sl()))
    ..registerLazySingleton<BookingRepository>(
      () => BookingRepositoryImpl(sl()),
    )
    ..registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(sl()),
    )
    ..registerLazySingleton<OffersRepository>(() => OffersRepositoryImpl(sl()))
    ..registerLazySingleton<PaymentService>(() => const TapPaymentService())
    ..registerSingleton<SessionCubit>(SessionCubit(prefs, userStore));
}
