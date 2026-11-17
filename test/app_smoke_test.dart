import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/app.dart';
import 'package:lavender/core/session/session_cubit.dart';
import 'package:lavender/core/storage/app_prefs.dart';
import 'package:lavender/core/storage/user_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('LavenderApp shows the splash placeholder, then the shell', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => SessionCubit(AppPrefs(sp), UserStore(sp)),
        child: const LavenderApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Splash'), findsOneWidget);

    await tester.tap(find.text('Go to /home'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Account'), findsNothing); // Arabic by default
  });
}
