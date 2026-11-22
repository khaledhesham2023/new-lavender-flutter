import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../shared/session/session_cubit.dart';
import '../../../data/models/responses/offer.dart';
import '../../../shared/domain/repositories/offers_repository.dart';
import '../domain/entities/payment_outcome.dart';
import '../domain/services/payment_service.dart';
import 'purchase_offer_state.dart';

/// Port of `PurchaseOfferFragment`'s flow: pay with Tap, then (only after a
/// successful charge) `POST client/offers`.
class PurchaseOfferCubit extends Cubit<PurchaseOfferState> {
  PurchaseOfferCubit(this._repository, this._payments, this._session)
    : super(const PurchaseOfferState());

  final OffersRepository _repository;
  final PaymentService _payments;
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
