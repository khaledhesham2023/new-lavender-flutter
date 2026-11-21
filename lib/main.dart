import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/push/push_service.dart';
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
  await _initPush();
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

/// Firebase + push (T39). A failure (no Play services, bad config) must not stop
/// the app from starting: push is simply unavailable then.
Future<void> _initPush() async {
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
    await sl<PushService>().init();
  } catch (e) {
    debugPrint('Push setup failed: $e');
  }
}
