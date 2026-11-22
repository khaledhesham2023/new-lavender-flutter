import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/shared/session/session_cubit.dart';
import 'package:lavender/core/storage/app_prefs.dart';
import 'package:lavender/shared/session/user_store.dart';
import 'package:lavender/data/models/responses/offer.dart';
import 'package:lavender/data/repositories/offers_repository.dart';
import 'package:lavender/features/purchase_offer/purchase_offer_cubit.dart';
import 'package:lavender/features/purchase_offer/tap_payment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePayments implements TapPaymentService {
  PaymentOutcome outcome = const Paid('chg_1');
  int calls = 0;
  double? amount;
  String? lang;
  String? name;
  String? phone;

  @override
  Future<PaymentOutcome> pay({
    required double amount,
    required String lang,
    String? name,
    String? phone,
    String? email,
  }) async {
    calls++;
    this.amount = amount;
    this.lang = lang;
    this.name = name;
    this.phone = phone;
    return outcome;
  }
}

class _FakeOffers implements OffersRepository {
  ApiResult<OfferModel> buyResult = const ApiSuccess(OfferModel(id: 99));
  final List<int> bought = [];

  @override
  Future<ApiResult<OfferModel>> buy(int offerId) async {
    bought.add(offerId);
    return buyResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _offer = OfferModel(id: 5, price: 200, finalPrice: 150);

Future<PurchaseOfferCubit> _cubit(
  _FakePayments payments,
  _FakeOffers offers,
) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final session = SessionCubit(AppPrefs(prefs), UserStore(prefs));
  return PurchaseOfferCubit(offers, payments, session)
    ..setTerms(true)
    ..selectMethod();
}

void main() {
  group('PurchaseOfferState', () {
    test('canPay needs both the checkbox and the radio', () {
      const base = PurchaseOfferState();
      expect(base.canPay, isFalse);
      expect(base.copyWith(termsAccepted: true).canPay, isFalse);
      expect(base.copyWith(methodSelected: true).canPay, isFalse);
      expect(
        base.copyWith(termsAccepted: true, methodSelected: true).canPay,
        isTrue,
      );
    });
  });

  group('PurchaseOfferCubit.pay', () {
    test('does nothing until both boxes are checked', () async {
      final payments = _FakePayments();
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = PurchaseOfferCubit(
        _FakeOffers(),
        payments,
        SessionCubit(AppPrefs(prefs), UserStore(prefs)),
      )..setTerms(true);
      await cubit.pay(_offer);
      expect(payments.calls, 0);
    });

    test('a paid charge buys the offer and emits the purchased id', () async {
      final payments = _FakePayments();
      final offers = _FakeOffers();
      final cubit = await _cubit(payments, offers);
      await cubit.pay(_offer);
      expect(payments.amount, 150);
      expect(payments.lang, 'ar');
      expect(offers.bought, [5]);
      expect(cubit.state.purchasedId, 99);
      expect(cubit.state.saving, isFalse);
    });

    test('a cancelled sheet neither buys nor reports', () async {
      final payments = _FakePayments()..outcome = const Cancelled();
      final offers = _FakeOffers();
      final cubit = await _cubit(payments, offers);
      await cubit.pay(_offer);
      expect(offers.bought, isEmpty);
      expect(cubit.state.purchasedId, isNull);
      expect(cubit.state.paymentError, isNull);
    });

    test('a declined payment reports the message and never buys', () async {
      final payments = _FakePayments()..outcome = const Failed('Declined');
      final offers = _FakeOffers();
      final cubit = await _cubit(payments, offers);
      await cubit.pay(_offer);
      expect(offers.bought, isEmpty);
      expect(cubit.state.paymentError, 'Declined');
    });

    test('a failed purchase request surfaces its failure', () async {
      final payments = _FakePayments();
      final offers = _FakeOffers()..buyResult = const NetworkFailure();
      final cubit = await _cubit(payments, offers);
      await cubit.pay(_offer);
      expect(cubit.state.failure, isA<NetworkFailure>());
      expect(cubit.state.purchasedId, isNull);
      expect(cubit.state.saving, isFalse);
    });

    test('consume clears the one-shot effects', () async {
      final cubit = await _cubit(
        _FakePayments()..outcome = const Failed('x'),
        _FakeOffers(),
      );
      await cubit.pay(_offer);
      expect(cubit.state.paymentError, 'x');
      cubit.consume();
      expect(cubit.state.paymentError, isNull);
      expect(cubit.state.canPay, isTrue);
    });
  });

  group('paymentOutcomeFromResult', () {
    test('a successful charge is paid', () {
      final out = paymentOutcomeFromResult({
        'sdk_result': 'SUCCESS',
        'trx_mode': 'CHARGE',
        'charge_id': 'chg_123',
      });
      expect(out, isA<Paid>());
      expect((out as Paid).chargeId, 'chg_123');
    });

    test('success of another transaction mode is not a payment', () {
      for (final mode in ['AUTHORIZE', 'SAVE_CARD', 'TOKENIZE']) {
        final out = paymentOutcomeFromResult({
          'sdk_result': 'SUCCESS',
          'trx_mode': mode,
          'charge_id': 'chg_123',
        });
        expect(out, isA<Failed>(), reason: mode);
      }
    });

    test('success without a charge id is not a payment', () {
      expect(
        paymentOutcomeFromResult({'sdk_result': 'SUCCESS', 'trx_mode': 'CHARGE'}),
        isA<Failed>(),
      );
    });

    test('cancelled, failed and sdk error map to their outcomes', () {
      expect(
        paymentOutcomeFromResult({'sdk_result': 'CANCELLED'}),
        isA<Cancelled>(),
      );
      final failed = paymentOutcomeFromResult({
        'sdk_result': 'FAILED',
        'message': 'Declined',
      });
      expect((failed as Failed).message, 'Declined');
      final error = paymentOutcomeFromResult({
        'sdk_result': 'SDK_ERROR',
        'sdk_error_message': 'Bad key',
      });
      expect((error as Failed).message, 'Bad key');
    });

    test('anything else is a failure', () {
      expect(paymentOutcomeFromResult(null), isA<Failed>());
      expect(paymentOutcomeFromResult({'sdk_result': '??'}), isA<Failed>());
    });
  });
}
