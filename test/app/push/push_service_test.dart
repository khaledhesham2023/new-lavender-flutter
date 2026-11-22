import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lavender/app/push/push_service.dart';
import 'package:lavender/shared/session/session_cubit.dart';
import 'package:lavender/core/storage/app_prefs.dart';
import 'package:lavender/shared/session/user_store.dart';
import 'package:lavender/app/router/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

GoRouter _router() {
  Widget page(String name) => Scaffold(body: Text(name));
  return GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => page('splash')),
      GoRoute(path: Routes.home, builder: (_, _) => page('home')),
      GoRoute(path: Routes.authLogin, builder: (_, _) => page('login')),
      GoRoute(path: Routes.myReports, builder: (_, _) => page('reports')),
      GoRoute(
        path: Routes.appointmentDetails,
        builder: (_, _) => page('appointment'),
      ),
    ],
  );
}

String _at(GoRouter router) =>
    router.routerDelegate.currentConfiguration.last.matchedLocation;

Future<PushService> _service({required bool loggedIn}) async {
  SharedPreferences.setMockInitialValues({
    if (loggedIn) AppPrefs.keyLoginStatus: true,
  });
  final sp = await SharedPreferences.getInstance();
  final prefs = AppPrefs(sp);
  return PushService(prefs, SessionCubit(prefs, UserStore(sp)));
}

Future<GoRouter> _pump(WidgetTester tester, PushService service) async {
  final router = _router();
  service.attachRouter(router);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('without a router the tap waits for the splash', (tester) async {
    final service = await _service(loggedIn: true);
    service.openTarget(Routes.myReports);
    expect(service.takePendingTarget(), Routes.myReports);
    expect(service.takePendingTarget(), isNull);
  });

  testWidgets('a tap on the splash is kept as pending', (tester) async {
    final service = await _service(loggedIn: true);
    final router = await _pump(tester, service);
    expect(_at(router), Routes.splash);
    service.openTarget(Routes.myReports);
    await tester.pumpAndSettle();
    expect(_at(router), Routes.splash);
    expect(service.takePendingTarget(), Routes.myReports);
  });

  testWidgets('a logged in user is taken to the target, back returns', (
    tester,
  ) async {
    final service = await _service(loggedIn: true);
    final router = await _pump(tester, service);
    router.go(Routes.home);
    await tester.pumpAndSettle();
    service.openTarget(Routes.appointmentDetailsOf(5));
    await tester.pumpAndSettle();
    expect(_at(router), Routes.appointmentDetailsOf(5));
    router.pop();
    await tester.pumpAndSettle();
    expect(_at(router), Routes.home);
  });

  testWidgets('the Home target goes to Home instead of stacking it', (
    tester,
  ) async {
    final service = await _service(loggedIn: true);
    final router = await _pump(tester, service);
    router.go(Routes.myReports);
    await tester.pumpAndSettle();
    service.openTarget(Routes.home);
    await tester.pumpAndSettle();
    expect(_at(router), Routes.home);
    expect(router.canPop(), isFalse);
  });

  testWidgets('from an auth screen it goes Home first, then the target', (
    tester,
  ) async {
    final service = await _service(loggedIn: true);
    final router = await _pump(tester, service);
    router.go(Routes.authLogin);
    await tester.pumpAndSettle();
    service.openTarget(Routes.myReports);
    await tester.pumpAndSettle();
    expect(_at(router), Routes.myReports);
    router.pop();
    await tester.pumpAndSettle();
    expect(_at(router), Routes.home);
  });

  testWidgets('guests ignore the tap', (tester) async {
    final service = await _service(loggedIn: false);
    final router = await _pump(tester, service);
    router.go(Routes.authLogin);
    await tester.pumpAndSettle();
    service.openTarget(Routes.myReports);
    await tester.pumpAndSettle();
    expect(_at(router), Routes.authLogin);
    expect(service.takePendingTarget(), isNull);
  });

  test('notification ids are per second and stay within an Int', () {
    final a = notificationId(DateTime.fromMillisecondsSinceEpoch(1700000000000));
    final b = notificationId(DateTime.fromMillisecondsSinceEpoch(1700000001500));
    expect(a, 1700000000);
    expect(b, 1700000001);
    expect(a, lessThan(0x7fffffff));
  });
}
