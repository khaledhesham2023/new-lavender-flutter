import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/app.dart';
import 'package:lavender/app/deeplink/deep_link_service.dart';
import 'package:lavender/app/di/injection.dart';
import 'package:lavender/core/push/device_token.dart';
import 'package:lavender/app/push/push_service.dart';
import 'package:lavender/shared/session/session_cubit.dart';
import 'package:lavender/core/storage/app_prefs.dart';
import 'package:lavender/shared/session/user_store.dart';
import 'package:lavender/features/auth/start_now_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _boot(WidgetTester tester, Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final sp = await SharedPreferences.getInstance();
  final prefs = AppPrefs(sp);
  final session = SessionCubit(prefs, UserStore(sp));
  await sl.reset();
  sl
    ..registerSingleton<AppPrefs>(prefs)
    ..registerSingleton<SessionCubit>(session)
    // Splash fetches the token; push taps need the service (T39). No Firebase here.
    ..registerSingleton(
      DeviceTokenProvider(prefs, fetchFcmToken: () async => null),
    )
    ..registerSingleton(PushService(prefs, session))
    // App Links (T40): no platform channel in tests; init failures are caught.
    ..registerSingleton(DeepLinkService(sl<PushService>(), session));
  await tester.pumpWidget(
    BlocProvider.value(value: session, child: const LavenderApp()),
  );
  // Logo animation (Lottie, once) + loader GIF timer.
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
}

void main() {
  testWidgets('first launch: splash then onboarding, 3 taps reach auth',
      (tester) async {
    await _boot(tester, {});
    expect(find.text('التالي'), findsOneWidget);

    await tester.tap(find.text('التالي'));
    await tester.pump();
    await tester.tap(find.text('التالي'));
    await tester.pump();
    expect(find.text('ابدأ الان'), findsOneWidget);

    await tester.tap(find.text('ابدأ الان'));
    // Start now has a looping Lottie, so pumpAndSettle would never finish.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(StartNowScreen), findsOneWidget);
    expect(sl<AppPrefs>().isFirstTime, isFalse);
  });

  testWidgets('not first launch and logged out: splash goes to auth',
      (tester) async {
    await _boot(tester, {AppPrefs.keyFirstTime: false});
    expect(find.byType(StartNowScreen), findsOneWidget);
  });
}
