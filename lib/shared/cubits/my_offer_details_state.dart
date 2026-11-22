import 'package:equatable/equatable.dart';
import '../../core/network/api_result.dart';
import '../../data/models/responses/offer.dart';

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
