import 'package:equatable/equatable.dart';
import '../../../core/network/api_result.dart';

class PurchaseOfferState extends Equatable {
  final bool termsAccepted;

  /// The single "credit cards" radio (`rbPayment`).
  final bool methodSelected;

  /// True while `POST client/offers` runs (Android's loading button). The Tap
  /// sheet itself is not "loading": it is a separate screen.
  final bool saving;

  /// One-shot effects, reset by [PurchaseOfferCubit.consume].
  final int? purchasedId;
  final String? paymentError;
  final ApiFailure<dynamic>? failure;

  const PurchaseOfferState({
    this.termsAccepted = false,
    this.methodSelected = false,
    this.saving = false,
    this.purchasedId,
    this.paymentError,
    this.failure,
  });

  /// `isButtonEnabled()`: both the checkbox and the radio must be checked.
  bool get canPay => termsAccepted && methodSelected;

  PurchaseOfferState copyWith({
    bool? termsAccepted,
    bool? methodSelected,
    bool? saving,
    int? purchasedId,
    String? paymentError,
    ApiFailure<dynamic>? failure,
  }) => PurchaseOfferState(
    termsAccepted: termsAccepted ?? this.termsAccepted,
    methodSelected: methodSelected ?? this.methodSelected,
    saving: saving ?? this.saving,
    purchasedId: purchasedId,
    paymentError: paymentError,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    termsAccepted,
    methodSelected,
    saving,
    purchasedId,
    paymentError,
    failure,
  ];
}
