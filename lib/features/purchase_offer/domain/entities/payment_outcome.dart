/// Result of one payment attempt.
sealed class PaymentOutcome {
  const PaymentOutcome();
}

/// The charge succeeded; [chargeId] is the payment provider's charge id.
class Paid extends PaymentOutcome {
  final String chargeId;

  const Paid(this.chargeId);
}

/// The user closed the payment sheet without paying.
class Cancelled extends PaymentOutcome {
  const Cancelled();
}

/// The payment was declined or the SDK failed. [message] may be empty.
class Failed extends PaymentOutcome {
  final String message;

  const Failed(this.message);
}
