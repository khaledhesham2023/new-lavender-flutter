import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../data/models/requests/offer_requests.dart';
import '../../../data/models/responses/offer.dart';
import '../../../data/repositories/repository_parsers.dart';
import '../../domain/repositories/offers_repository.dart';

/// [OffersRepository] over the Lavender API.
class OffersRepositoryImpl implements OffersRepository {
  OffersRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<ApiResult<List<OfferModel>>> bySpecialty(int id) =>
      _api.call((s) => s.offers(id), parse: parseList(OfferModel.fromJson));

  @override
  Future<ApiResult<OfferModel>> details(int id) =>
      _api.call((s) => s.offer(id), parse: parseObject(OfferModel.fromJson));

  @override
  Future<ApiResult<MyOffersData>> myOffers() =>
      _api.call((s) => s.myOffers(), parse: parseObject(MyOffersData.fromJson));

  @override
  Future<ApiResult<OfferModel>> myOfferDetails(int id) =>
      _api.call((s) => s.myOffer(id), parse: parseObject(OfferModel.fromJson));

  /// Called after a successful payment; returns the purchased (user) offer.
  @override
  Future<ApiResult<OfferModel>> buy(int offerId) => _api.call(
    (s) => s.buyOffer(BuyOfferRequest(offerId: offerId).toJson()),
    parse: parseObject(OfferModel.fromJson),
  );

  @override
  Future<ApiResult<SessionDetailsModel>> session(int id) => _api.call(
    (s) => s.session(id),
    parse: parseObject(SessionDetailsModel.fromJson),
  );
}
