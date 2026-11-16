import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/core/theme/app_assets.dart';
import 'package:lavender/core/widgets/app_svg.dart';
import 'package:lavender/core/widgets/app_toast.dart';
import 'package:lavender/core/widgets/failure_toast.dart';
import 'package:lavender/core/widgets/progress_button.dart';
import 'package:lavender/core/widgets/star_rating.dart';
import 'package:lavender/core/widgets/state_view.dart';
import 'package:lavender/core/widgets/success_dialog.dart';
import 'package:lavender/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

const _png = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

const _svg = '<svg xmlns="http://www.w3.org/2000/svg" width="10" height="10"/>';

/// Hosts [child] with real l10n in [locale]. SVG assets are stubbed so the tests
/// do not depend on the asset bundle contents.
Widget _host(Widget child, {String locale = 'en'}) => MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Stub svg/gif assets so tests do not depend on the asset bundle contents.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      final key = Uri.decodeFull(String.fromCharCodes(message!.buffer.asUint8List()));
      if (key.endsWith('.svg')) {
        return Uint8List.fromList(_svg.codeUnits).buffer.asByteData();
      }
      if (key.endsWith('.gif') || key.endsWith('.png')) {
        return Uint8List.fromList(_png).buffer.asByteData();
      }
      return null;
    });
  });

  group('StarRating', () {
    int count(WidgetTester t, String asset) =>
        t.widgetList<AppSvg>(find.byType(AppSvg)).where((s) => s.asset == asset).length;

    testWidgets('3.5 renders 3 full, 1 half, 1 empty', (t) async {
      await t.pumpWidget(_host(const StarRating(score: 3.5)));
      expect(count(t, AppAssets.icFullStar), 3);
      expect(count(t, AppAssets.icHalf), 1);
      expect(count(t, AppAssets.icEmptyStar), 1);
    });

    testWidgets('3.7 rounds to the nearest half', (t) async {
      await t.pumpWidget(_host(const StarRating(score: 3.7)));
      expect(count(t, AppAssets.icFullStar), 3);
      expect(count(t, AppAssets.icHalf), 1);
    });

    testWidgets('tap picks whole stars (LTR)', (t) async {
      double? picked;
      await t.pumpWidget(_host(Center(
        child: StarRating(score: 0, readOnly: false, size: 40, onChanged: (v) => picked = v),
      )));
      final box = t.getRect(find.byType(StarRating));
      await t.tapAt(Offset(box.left + 3, box.center.dy));
      expect(picked, 1);
      await t.tapAt(Offset(box.right - 3, box.center.dy));
      expect(picked, 5);
    });
  });

  group('ProgressButton', () {
    testWidgets('taps work normally', (t) async {
      var taps = 0;
      await t.pumpWidget(_host(ProgressButton(text: 'Go', onPressed: () => taps++)));
      await t.tap(find.text('Go'));
      expect(taps, 1);
    });

    testWidgets('loading shows spinner, hides text, ignores taps', (t) async {
      var taps = 0;
      await t.pumpWidget(_host(ProgressButton(text: 'Go', loading: true, onPressed: () => taps++)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Go'), findsNothing);
      await t.tap(find.byType(ProgressButton));
      expect(taps, 0);
    });

    testWidgets('disabled ignores taps', (t) async {
      var taps = 0;
      await t.pumpWidget(_host(ProgressButton(text: 'Go', enabled: false, onPressed: () => taps++)));
      await t.tap(find.text('Go'));
      expect(taps, 0);
    });
  });

  group('StateView', () {
    testWidgets('serverError has no button without onRetry, Retry with it', (t) async {
      await t.pumpWidget(_host(const StateView.serverError()));
      expect(find.text('Server Error'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);

      var retried = 0;
      await t.pumpWidget(_host(StateView.serverError(onRetry: () => retried++)));
      await t.tap(find.text('Retry'));
      expect(retried, 1);
    });

    testWidgets('forFailure picks the variant', (t) async {
      await t.pumpWidget(_host(StateView.forFailure(const NetworkFailure<int>(), onRetry: () {})));
      expect(find.text('No Internet Connection'), findsOneWidget);
      await t.pumpWidget(_host(StateView.forFailure(const ServerFailure<int>(500, 'x'))));
      expect(find.text('Server Error'), findsOneWidget);
    });

    testWidgets('empty shows given texts and button', (t) async {
      var tapped = false;
      await t.pumpWidget(_host(StateView.empty(
        icon: AppAssets.icNoData,
        title: 'Nothing',
        body: 'Here',
        buttonTitle: 'Back',
        onButton: () => tapped = true,
      )));
      expect(find.text('Nothing'), findsOneWidget);
      expect(find.text('Here'), findsOneWidget);
      await t.tap(find.text('Back'));
      expect(tapped, isTrue);
    });
  });

  group('AppToast', () {
    testWidgets('shows, then fades out and removes after the duration', (t) async {
      late BuildContext ctx;
      await t.pumpWidget(_host(Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      })));
      AppToast.show(ctx, 'Saved', ToastType.success);
      await t.pump();
      expect(find.text('Saved'), findsOneWidget);
      await t.pump(const Duration(seconds: 3));
      await t.pumpAndSettle();
      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('a new toast replaces the old one', (t) async {
      late BuildContext ctx;
      await t.pumpWidget(_host(Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      })));
      AppToast.show(ctx, 'First', ToastType.normal);
      await t.pump();
      AppToast.show(ctx, 'Second', ToastType.failed);
      await t.pump();
      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsOneWidget);
      AppToast.dismiss();
      await t.pump();
    });

    testWidgets('showFailureToast maps failures to messages', (t) async {
      late BuildContext ctx;
      await t.pumpWidget(_host(Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      })));
      showFailureToast(ctx, const ServerFailure<int>(400, 'Bad phone'));
      await t.pump();
      expect(find.text('Bad phone'), findsOneWidget);

      showFailureToast(ctx, const NetworkFailure<int>());
      await t.pump();
      expect(find.text('Connection Error'), findsOneWidget);

      showFailureToast(ctx, const UnknownFailure<int>());
      await t.pump();
      expect(find.text('Connection Error'), findsOneWidget);

      showFailureToast(ctx, const UnknownFailure<int>('Oops'));
      await t.pump();
      expect(find.text('Oops'), findsOneWidget);
      AppToast.dismiss();
      await t.pump();
    });
  });

  testWidgets('success dialog closes itself after 2 s and cannot be dismissed', (t) async {
    late BuildContext ctx;
    await t.pumpWidget(_host(Builder(builder: (c) {
      ctx = c;
      return const SizedBox();
    })));
    var closed = false;
    showSuccessDialog(ctx, 'Done!').then((_) => closed = true);
    await t.pump();
    expect(find.text('Done!'), findsOneWidget);

    await t.tapAt(const Offset(2, 2)); // barrier tap must not close it
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Done!'), findsOneWidget);

    await t.pump(const Duration(seconds: 2));
    await t.pumpAndSettle();
    expect(find.text('Done!'), findsNothing);
    expect(closed, isTrue);
  });
}
