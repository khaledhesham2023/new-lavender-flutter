import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../storage/app_prefs.dart';

final GetIt sl = GetIt.instance;

/// Registers app-wide singletons. Call once from `main()` before `runApp`.
/// Repositories/cubits (T08+) register here and receive deps via constructors.
Future<void> configureDependencies() async {
  sl.registerSingleton<AppPrefs>(await AppPrefs.create());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<AppPrefs>()));
}
