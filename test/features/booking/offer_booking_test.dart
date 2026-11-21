import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lavender/core/di/injection.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/core/widgets/dashed_border_box.dart';
import 'package:lavender/data/models/requests/appointment_requests.dart';
import 'package:lavender/data/models/requests/booking_draft.dart';
import 'package:lavender/data/models/responses/appointment.dart';
import 'package:lavender/data/models/responses/doctor.dart';
import 'package:lavender/data/models/responses/offer.dart';
import 'package:lavender/data/repositories/booking_repository.dart';
import 'package:lavender/data/repositories/offers_repository.dart';
import 'package:lavender/features/booking/appointment_type_sheet.dart';
import 'package:lavender/features/booking/book_appointment_cubit.dart';
import 'package:lavender/features/booking/book_with_offer_screen.dart';
import 'package:lavender/features/booking/session_requested_cubit.dart';
import 'package:lavender/features/booking/session_requested_screen.dart';
import 'package:lavender/l10n/generated/app_localizations.dart';
import 'package:lavender/router/routes.dart';
import 'package:material_ui/material_ui.dart';

class _FakeBookingRepository implements BookingRepository {
  final List<SaveAppointmentRequest> saved = [];

  @override
  Future<ApiResult<AppointmentData>> save(SaveAppointmentRequest r) async {
    saved.add(r);
    return const ApiSuccess(AppointmentData(id: 99));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOffersRepository implements OffersRepository {
  ApiResult<SessionDetailsModel> sessionResult = const ApiSuccess(_session);

  @override
  Future<ApiResult<SessionDetailsModel>> session(int id) async => sessionResult;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _offer = OfferModel(
  id: 5,
  name: 'Hollywood Veneers',
  description: 'desc',
  number: 6,
  usedNumber: 2,
);
const _offer2 = OfferModel(
  id: 6,
  name: 'Whitening',
  description: 'desc2',
  number: 3,
  usedNumber: 0,
);

const _draft = BookingDraft(
  doctorId: 7,
  doctorName: 'Dr Test',
  doctorSpecialization: 'Dentist',
  rate: 4.5,
  reviewsCount: 12,
  date: '2025-03-08T00:00:00.000000Z',
  formattedDate: 'Saturday, 08 March 2025',
  day: 'Saturday',
  time: '10:00',
  duration: '30',
  examinationPrice: '150',
  userOfferId: 5,
);

const _session = SessionDetailsModel(
  id: 77,
  doctor: DoctorModel(name: 'Dr Test', specialty: 'Dentist', duration: '30'),
  offer: _offer,
  formatedDate: 'Saturday, 08 March 2025',
  from: '10:00',
  to: '10:30',
  number: 6,
  usedNumber: 2,
);

Widget _host(Widget child) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

/// A button that opens the sheet and records what it resolved to.
class _SheetLauncher extends StatelessWidget {
  final List<OfferModel> offers;
  final void Function(OfferModel?) onResult;

  const _SheetLauncher({required this.offers, required this.onResult});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () async => onResult(
              await showAppointmentTypeSheet(
                context,
                price: '150',
                offers: offers,
              ),
            ),
            child: const Text('open'),
          ),
        ),
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => initializeDateFormatting());

  group('AppointmentTypeSheet', () {
    Future<void> open(WidgetTester t, void Function(OfferModel?) onResult) async {
      await t.pumpWidget(
        _host(_SheetLauncher(offers: const [_offer, _offer2], onResult: onResult)),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
    }

    testWidgets('lists normal examination (price as 150.0) then the offers', (t) async {
      await open(t, (_) {});
      expect(find.text('Examination Book'), findsOneWidget);
      expect(find.text('Book normal examination for 150.0 SAR'), findsOneWidget);
      expect(find.text('Hollywood Veneers'), findsOneWidget);
      expect(find.text('Remaining (6/2) session/s'), findsOneWidget);
      expect(find.text('Remaining (3/0) session/s'), findsOneWidget);
      // The normal row has no sessions line: only two remaining texts.
      expect(find.textContaining('Remaining ('), findsNWidgets(2));
      expect(find.byType(DashedBorderBox), findsNWidgets(3));
    });

    testWidgets('confirm with nothing selected shows the toast and stays open', (t) async {
      OfferModel? result;
      var called = false;
      await open(t, (r) {
        result = r;
        called = true;
      });
      await t.tap(find.text('Confirm'));
      await t.pump();
      expect(find.text('Select an appointment'), findsOneWidget);
      expect(called, isFalse);
      expect(result, isNull);
      await t.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('selecting the normal row resolves to the id -1 sentinel', (t) async {
      OfferModel? result;
      await open(t, (r) => result = r);
      await t.tap(
        find.descendant(
          of: find.byType(DashedBorderBox).first,
          matching: find.byType(GestureDetector),
        ),
      );
      await t.pumpAndSettle();
      await t.tap(find.text('Confirm'));
      await t.pumpAndSettle();
      expect(result?.id, normalExaminationId);
    });

    testWidgets('tapping a row or any of its texts selects it', (t) async {
      OfferModel? result;
      await open(t, (r) => result = r);
      await t.tap(find.text('Whitening')); // a child text
      await t.pump();
      await t.tap(find.text('Remaining (6/2) session/s')); // another row's child
      await t.pump();
      await t.tap(find.text('Confirm'));
      await t.pumpAndSettle();
      expect(result?.id, 5);
    });

    testWidgets('single selection, and tapping a checked radio unchecks it', (t) async {
      OfferModel? result;
      await open(t, (r) => result = r);
      final radios = find.descendant(
        of: find.byType(DashedBorderBox),
        matching: find.byType(GestureDetector),
      );
      expect(radios, findsNWidgets(3));
      await t.tap(radios.at(1));
      await t.pump();
      await t.ensureVisible(radios.at(2)); // the third row starts below the fold
      await t.pumpAndSettle();
      await t.tap(radios.at(2)); // moves the selection
      await t.pump();
      await t.tap(radios.at(2)); // unchecks
      await t.pump();
      await t.ensureVisible(find.text('Confirm'));
      await t.pumpAndSettle();
      await t.tap(find.text('Confirm'));
      await t.pump();
      expect(find.text('Select an appointment'), findsOneWidget);
      await t.pumpAndSettle(const Duration(seconds: 5));

      await t.tap(radios.at(1));
      await t.pump();
      await t.tap(find.text('Confirm'));
      await t.pumpAndSettle();
      expect(result?.id, 5);
    });
  });

  group('BookAppointmentCubit with an offer', () {
    test('save carries user_offer_id; normal booking leaves it null', () async {
      final repo = _FakeBookingRepository();
      final withOffer = BookAppointmentCubit(repo, _draft);
      await withOffer.book('note');
      expect(repo.saved.single.userOfferId, 5);
      expect(withOffer.state.bookedId, 99);
      await withOffer.close();

      final repo2 = _FakeBookingRepository();
      final normal = BookAppointmentCubit(
        repo2,
        const BookingDraft(doctorId: 7, date: '2025-03-08T00:00:00.000000Z', time: '10:00'),
      );
      await normal.book('');
      expect(repo2.saved.single.userOfferId, isNull);
      await normal.close();
    });
  });

  group('SessionRequestedCubit', () {
    test('loads the session, or reports the failure', () async {
      final repo = _FakeOffersRepository();
      final cubit = SessionRequestedCubit(repo, 77);
      await cubit.load();
      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.session?.id, 77);

      repo.sessionResult = NetworkFailure();
      await cubit.load();
      expect(cubit.state.status, ViewStatus.failure);
      expect(cubit.state.failure, isA<NetworkFailure>());
      await cubit.close();
    });
  });

  group('screens', () {
    late _FakeBookingRepository booking;
    late _FakeOffersRepository offers;

    setUp(() {
      booking = _FakeBookingRepository();
      offers = _FakeOffersRepository();
      if (sl.isRegistered<BookingRepository>()) sl.unregister<BookingRepository>();
      if (sl.isRegistered<OffersRepository>()) sl.unregister<OffersRepository>();
      sl.registerSingleton<BookingRepository>(booking);
      sl.registerSingleton<OffersRepository>(offers);
    });

    tearDown(() {
      sl.unregister<BookingRepository>();
      sl.unregister<OffersRepository>();
    });

    testWidgets('book with offer shows offer card, no price, and books with the offer id', (t) async {
      await t.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) =>
                const BookWithOfferScreen(draft: _draft, offer: _offer),
          ),
          GoRoute(
            path: Routes.sessionRequested,
            builder: (_, s) => Text('session ${s.pathParameters["id"]}'),
          ),
        ],
      );
      await t.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      await t.pump();

      expect(find.text('Book an offer'), findsOneWidget);
      expect(find.text('Hollywood Veneers'), findsOneWidget);
      expect(find.text('Remaining (6/2) session/s'), findsOneWidget);
      expect(find.text('Dr Test'), findsOneWidget);
      expect(find.textContaining('SAR'), findsNothing);

      await t.tap(find.text('Confirm Reservation'));
      await t.pump();
      await t.pump();
      expect(booking.saved.single.userOfferId, 5);
      expect(booking.saved.single.doctorId, 7);
      await t.pumpAndSettle();
      expect(find.text('session 99'), findsOneWidget);
    });

    testWidgets('session requested: network failure shows retry + back home, server error has no buttons', (t) async {
      await t.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => t.binding.setSurfaceSize(null));
      offers.sessionResult = NetworkFailure();
      await t.pumpWidget(_host(const SessionRequestedScreen(sessionId: 77)));
      await t.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Back Home'), findsNothing);

      offers.sessionResult = const ApiSuccess(_session);
      await t.tap(find.text('Retry'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
      expect(find.text('Hollywood Veneers'), findsOneWidget);
      expect(find.text('Back Home'), findsNothing);
    });

    testWidgets('session requested: server error shows the server error view only', (t) async {
      await t.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => t.binding.setSurfaceSize(null));
      offers.sessionResult = ServerFailure(500, 'x');
      await t.pumpWidget(_host(const SessionRequestedScreen(sessionId: 77)));
      await t.pumpAndSettle();
      expect(find.text('Retry'), findsNothing);
      expect(find.text('Back Home'), findsNothing);
      expect(find.text('Hollywood Veneers'), findsNothing);
    });

    testWidgets('session requested screen shows the offer session details', (t) async {
      await t.binding.setSurfaceSize(const Size(400, 1400));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(_host(const SessionRequestedScreen(sessionId: 77)));
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));

      expect(find.text('Hollywood Veneers'), findsOneWidget);
      expect(find.text('Remaining (6/2) session/s'), findsOneWidget);
      expect(find.text('Saturday, 08 March 2025'), findsOneWidget);
      expect(find.text('Dr Test'), findsOneWidget);
      expect(find.textContaining('#77'), findsOneWidget);
    });
  });
}
