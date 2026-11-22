import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../domain/repositories/offers_repository.dart';
import 'my_offer_details_state.dart';

/// Port of the `GetMyOfferDetails` event of `OffersViewModel`. The id is a user-offer
/// id (it can also come from a `user_offer` notification, T39).
class MyOfferDetailsCubit extends Cubit<MyOfferDetailsState> {
  MyOfferDetailsCubit(this._repository, this.id)
    : super(const MyOfferDetailsState());

  final OffersRepository _repository;
  final int id;

  Future<void> load() async {
    emit(const MyOfferDetailsState(status: ViewStatus.loading));
    final result = await _repository.myOfferDetails(id);
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(MyOfferDetailsState(status: ViewStatus.success, offer: data));
      case ApiFailure():
        emit(MyOfferDetailsState(status: ViewStatus.failure, failure: result));
    }
  }
}
