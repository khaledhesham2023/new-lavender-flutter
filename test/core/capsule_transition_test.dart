import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('capsule transition pushes and pops a page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: Text('second')),
              ),
            ),
            child: const Text('first'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('first'));
    await tester.pump(); // route inserted, animation at 0
    await tester.pump(const Duration(milliseconds: 100)); // capsule spinning in
    expect(find.text('second', skipOffstage: false), findsOneWidget);
    expect(find.text('second'), findsNothing); // hidden until covered

    await tester.pump(const Duration(milliseconds: 300)); // halves parting
    expect(find.text('second'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('second'), findsOneWidget);

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(find.text('second'), findsNothing);
    expect(find.text('first'), findsOneWidget);
  });
}
