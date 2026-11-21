import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../core/session/session_cubit.dart';
import '../../data/models/responses/offer.dart';
import '../../data/repositories/offers_repository.dart';
import 'tap_payment_service.dart';

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

/// Port of `PurchaseOfferFragment`'s flow: pay with Tap, then (only after a
/// successful charge) `POST client/offers`.
class PurchaseOfferCubit extends Cubit<PurchaseOfferState> {
  PurchaseOfferCubit(this._repository, this._payments, this._session)
    : super(const PurchaseOfferState());

  final OffersRepository _repository;
  final TapPaymentService _payments;
  final SessionCubit _session;

  bool _busy = false;

  void setTerms(bool value) => emit(state.copyWith(termsAccepted: value));

  void selectMethod() => emit(state.copyWith(methodSelected: true));

  Future<void> pay(OfferModel offer) async {
    final id = offer.id;
    if (_busy || !state.canPay || id == null) return;
    _busy = true;
    try {
      final user = _session.state.user;
      final outcome = await _payments.pay(
        amount: offer.finalPrice ?? 0,
        lang: _session.state.languageCode,
        name: user?.name,
        phone: user?.phone,
        email: user?.email,
      );
      if (isClosed) return;
      switch (outcome) {
        case Cancelled():
          return;
        case Failed(:final message):
          emit(state.copyWith(paymentError: message));
        case Paid():
          emit(state.copyWith(saving: true));
          final result = await _repository.buy(id);
          if (isClosed) return;
          switch (result) {
            case ApiSuccess(:final data):
              // Android only navigates when the response carries the id.
              emit(state.copyWith(saving: false, purchasedId: data.id));
            case ApiFailure():
              emit(state.copyWith(saving: false, failure: result));
          }
      }
    } finally {
      _busy = false;
    }
  }

  /// Clears the one-shot effects after the screen handled them.
  void consume() => emit(state.copyWith());
}
