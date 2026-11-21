import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/session/session_cubit.dart';
import 'core/theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Not awaited: the platform call can stay pending forever when the process is
  // (re)started in the background, which left the app on the native splash.
  // The manifest already locks the activity to portrait.
  unawaited(
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  );
  await initializeDateFormatting();
  await configureDependencies();
  // One fixed navigation bar for the whole app (never changes per screen).
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: AppColors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  runApp(
    BlocProvider.value(value: sl<SessionCubit>(), child: const LavenderApp()),
  );
}
