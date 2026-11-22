import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/app/di/injection.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/shared/session/session_cubit.dart';
import 'package:lavender/core/storage/app_prefs.dart';
import 'package:lavender/shared/session/user_store.dart';
import 'package:lavender/core/widgets/progress_button.dart';
import 'package:lavender/data/models/responses/offer.dart';
import 'package:lavender/data/models/responses/speciality.dart';
import 'package:lavender/shared/domain/repositories/offers_repository.dart';
import 'package:lavender/features/purchase_offer/offer_purchased_screen.dart';
import 'package:lavender/features/purchase_offer/purchase_offer_screen.dart';
import 'package:lavender/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _offer = OfferModel(
  id: 5,
  name: 'Hollywood Veneers',
  description: 'Brief text',
  price: 200,
  finalPrice: 150,
  discount: 25,
  number: 3,
  startDate: '1 Jan',
  endDate: '5 Mar',
  specialtyModel: SpecialityModel(id: 1, name: 'Dentistry'),
);

class _FakeOffers implements OffersRepository {
  ApiResult<OfferModel> myOfferResult = const ApiSuccess(_offer);

  @override
  Future<ApiResult<OfferModel>> myOfferDetails(int id) async => myOfferResult;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

Future<_FakeOffers> _setup() async {
  SharedPreferences.setMockInitialValues({});
  final sp = await SharedPreferences.getInstance();
  final prefs = AppPrefs(sp);
  final offers = _FakeOffers();
  await sl.reset();
  sl
    ..registerSingleton<OffersRepository>(offers)
    ..registerSingleton<SessionCubit>(SessionCubit(prefs, UserStore(sp)));
  return offers;
}

bool _payEnabled(WidgetTester t) =>
    t.widget<ProgressButton>(find.byType(ProgressButton)).enabled;

void main() {
  testWidgets('purchase screen: pay needs the terms and the card radio', (
    t,
  ) async {
    await _setup();
    await t.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(_host(const PurchaseOfferScreen(offer: _offer)));
    await t.pump();

    expect(find.text('Hollywood Veneers'), findsOneWidget);
    expect(find.text('Brief text'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
    expect(find.text('150 SAR'), findsNWidgets(2)); // card + total
    expect(find.text('200 SAR'), findsNWidgets(2)); // card + before discount
    expect(_payEnabled(t), isFalse);

    await t.tap(find.text('Agree to the'));
    await t.pump();
    expect(_payEnabled(t), isFalse);

    await t.tap(find.text('Credit Cards'));
    await t.pump();
    expect(_payEnabled(t), isTrue);

    await t.tap(find.text('Agree to the'));
    await t.pump();
    expect(_payEnabled(t), isFalse);
  });

  testWidgets('offer purchased screen shows the purchased offer', (t) async {
    await _setup();
    await t.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(_host(const OfferPurchasedScreen(userOfferId: 9)));
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));

    expect(find.text('The offer has been successfully obtained'),
        findsOneWidget);
    expect(find.text('Hollywood Veneers'), findsOneWidget);
    expect(find.text('1 Jan : 5 Mar'), findsOneWidget);
    expect(find.text('Check the doctors'), findsOneWidget);
    expect(
      find.text('This offer applies to all doctors in the specialty of Dentistry'),
      findsOneWidget,
    );
  });

  testWidgets('offer purchased screen shows the retry view offline', (t) async {
    final offers = await _setup();
    offers.myOfferResult = const NetworkFailure();
    await t.pumpWidget(_host(const OfferPurchasedScreen(userOfferId: 9)));
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Hollywood Veneers'), findsNothing);
  });
}
