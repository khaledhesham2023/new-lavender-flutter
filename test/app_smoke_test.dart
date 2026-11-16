import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/app.dart';

void main() {
  testWidgets('LavenderApp builds a MaterialApp', (tester) async {
    await tester.pumpWidget(const LavenderApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
