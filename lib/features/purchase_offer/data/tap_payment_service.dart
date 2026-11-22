import 'package:flutter/foundation.dart';
import 'package:go_sell_sdk_flutter/go_sell_sdk_flutter.dart';
import 'package:go_sell_sdk_flutter/model/models.dart';

import '../../../core/config/env.dart';

/// Result of one Tap payment attempt.
sealed class PaymentOutcome {
  const PaymentOutcome();
}

/// The charge succeeded; [chargeId] is Tap's charge id.
class Paid extends PaymentOutcome {
  final String chargeId;

  const Paid(this.chargeId);
}

/// The user closed the Tap sheet without paying.
class Cancelled extends PaymentOutcome {
  const Cancelled();
}

/// The payment was declined or the SDK failed. [message] may be empty.
class Failed extends PaymentOutcome {
  final String message;

  const Failed(this.message);
}

/// Port of `TapPaymentHelper.kt`. The only file that imports the Tap plugin.
///
/// Mirrors the Android configuration: purchase mode, `SAR`, the customer built
/// from the logged-in user (full name in the first, middle and last name), card
/// saving and 3-D Secure on, no receipts, no items, windowed sheet.
class TapPaymentService {
  const TapPaymentService();

  /// Android passes `"999"` when the user has no phone.
  static const _fallbackPhone = '999';

  /// Android hard-codes the Saudi country code for the customer.
  static const _phoneCountryCode = '966';

  Future<PaymentOutcome> pay({
    required double amount,
    required String lang,
    String? name,
    String? phone,
    String? email,
  }) async {
    final key = Env.paymentKey;
    if (key.isEmpty) return const Failed('Payment key is not configured');
    try {
      // The plugin wants both keys; Android uses a single key for both modes.
      GoSellSdkFlutter.configureApp(
        productionSecretKey: key,
        sandBoxSecretKey: key,
        bundleId: 'com.alalmiya.lavender',
        lang: lang,
      );
      final fullName = name ?? '';
      GoSellSdkFlutter.sessionConfigurations(
        trxMode: TransactionMode.PURCHASE,
        transactionCurrency: 'SAR',
        amount: amount,
        customer: Customer(
          customerId: '',
          email: email ?? '',
          isdNumber: _phoneCountryCode,
          number: (phone == null || phone.isEmpty) ? _fallbackPhone : phone,
          firstName: fullName,
          middleName: fullName,
          lastName: fullName,
        ),
        paymentItems: <PaymentItem>[],
        taxes: <Tax>[],
        shippings: <Shipping>[],
        postURL: '',
        paymentDescription: '',
        paymentMetaData: <String, String>{},
        paymentReference: Reference(
          acquirer: '',
          gateway: '',
          payment: '',
          track: '',
          transaction: '',
          order: '',
        ),
        paymentStatementDescriptor: '',
        isUserAllowedToSaveCard: true,
        isRequires3DSecure: true,
        receipt: Receipt(false, false),
        authorizeAction: AuthorizeAction(
          type: AuthorizeActionType.CAPTURE,
          timeInHours: 0,
        ),
        merchantID: '',
        allowedCadTypes: CardType.ALL,
        sdkMode: SDKMode.Sandbox, // picks the sandbox key slot = our one key
        paymentType: PaymentType.CARD,
        allowsToSaveSameCardMoreThanOnce: false,
        cardHolderName: '',
        allowsToEditCardHolderName: false,
        appearanceMode: SDKAppearanceMode.windowed,
      );
      final result = await GoSellSdkFlutter.startPaymentSDK;
      return paymentOutcomeFromResult(result);
    } catch (e) {
      debugPrint('TapPaymentService.pay failed: $e');
      return Failed('$e');
    }
  }
}

/// Maps the plugin's result map. Only a successful *charge* counts as paid:
/// authorizations, saved cards and tokens must never trigger the purchase
/// (Android calls `buyOffer` only from `paymentSucceed`).
@visibleForTesting
PaymentOutcome paymentOutcomeFromResult(dynamic result) {
  if (result is! Map) return const Failed('');
  switch (result['sdk_result']) {
    case 'SUCCESS':
      final chargeId = result['charge_id']?.toString() ?? '';
      if (result['trx_mode'] == 'CHARGE' && chargeId.isNotEmpty) {
        return Paid(chargeId);
      }
      return Failed(result['message']?.toString() ?? '');
    case 'CANCELLED':
      return const Cancelled();
    case 'FAILED':
      return Failed(result['message']?.toString() ?? '');
    case 'SDK_ERROR':
      return Failed(
        result['sdk_error_message']?.toString() ??
            result['sdk_error_description']?.toString() ??
            '',
      );
    default:
      return const Failed('');
  }
}
