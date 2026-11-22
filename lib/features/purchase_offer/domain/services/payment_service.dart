import '../entities/payment_outcome.dart';

/// Takes a card payment. The presentation layer depends on this contract only;
/// `TapPaymentService` (data layer) implements it with the Tap SDK.
abstract interface class PaymentService {
  /// Charges [amount] SAR. [lang] is the UI language of the payment sheet;
  /// [name], [phone] and [email] describe the customer.
  Future<PaymentOutcome> pay({
    required double amount,
    required String lang,
    String? name,
    String? phone,
    String? email,
  });
}
