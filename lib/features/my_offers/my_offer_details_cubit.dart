import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../data/models/responses/offer.dart';
import '../../data/repositories/offers_repository.dart';

class MyOfferDetailsState extends Equatable {
  final ViewStatus status;
  final OfferModel? offer;
  final ApiFailure<dynamic>? failure;

  const MyOfferDetailsState({
    this.status = ViewStatus.initial,
    this.offer,
    this.failure,
  });

  @override
  List<Object?> get props => [status, offer, failure];
}

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
