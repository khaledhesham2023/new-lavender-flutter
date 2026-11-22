import 'package:equatable/equatable.dart';
import '../../../core/network/api_result.dart';
import '../../../data/models/responses/offer.dart';

class OfferDetailsState extends Equatable {
  final ViewStatus status;
  final OfferModel? offer;

  /// Failure of `details`; the screen picks the view from its type.
  final ApiFailure<dynamic>? failure;

  const OfferDetailsState({
    this.status = ViewStatus.initial,
    this.offer,
    this.failure,
  });

  /// The offer no longer exists (HTTP 404).
  bool get notFound =>
      failure is ServerFailure && (failure as ServerFailure).code == 404;

  @override
  List<Object?> get props => [status, offer, failure];
}
