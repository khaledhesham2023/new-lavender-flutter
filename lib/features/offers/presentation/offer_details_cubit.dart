import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../shared/domain/repositories/offers_repository.dart';
import 'offer_details_state.dart';

/// Port of the offer-details part of `OffersViewModel`.
class OfferDetailsCubit extends Cubit<OfferDetailsState> {
  OfferDetailsCubit(this._repository, this.id)
    : super(const OfferDetailsState());

  final OffersRepository _repository;
  final int id;

  Future<void> load() async {
    emit(const OfferDetailsState(status: ViewStatus.loading));
    final result = await _repository.details(id);
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(OfferDetailsState(status: ViewStatus.success, offer: data));
      case ApiFailure():
        emit(OfferDetailsState(status: ViewStatus.failure, failure: result));
    }
  }
}
