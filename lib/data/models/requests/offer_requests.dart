import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'offer_requests.g.dart';

/// Body of `BuyOfferRequest`.
@JsonSerializable(createFactory: false)
class BuyOfferRequest extends Equatable {
  final int? offerId;

  const BuyOfferRequest({this.offerId});

  Map<String, dynamic> toJson() => _$BuyOfferRequestToJson(this);

  @override
  @JsonKey(includeToJson: false)
  List<Object?> get props => [offerId];
}
