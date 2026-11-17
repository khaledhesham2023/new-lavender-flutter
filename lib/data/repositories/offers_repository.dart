import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../../core/network/endpoints.dart';
import '../models/requests/offer_requests.dart';
import '../models/responses/offer.dart';
import 'repository_parsers.dart';

class OffersRepository {
  OffersRepository(this._api);

  final ApiClient _api;

  Future<ApiResult<List<OfferModel>>> bySpecialty(int id) => _api.get(
    Endpoints.offers,
    query: {'specialty_id': id},
    parse: parseList(OfferModel.fromJson),
  );

  Future<ApiResult<OfferModel>> details(int id) =>
      _api.get(Endpoints.offer(id), parse: parseObject(OfferModel.fromJson));

  Future<ApiResult<MyOffersData>> myOffers() =>
      _api.get(Endpoints.myOffers, parse: parseObject(MyOffersData.fromJson));

  Future<ApiResult<OfferModel>> myOfferDetails(int id) =>
      _api.get(Endpoints.myOffer(id), parse: parseObject(OfferModel.fromJson));

  /// Called after a successful payment; returns the purchased (user) offer.
  Future<ApiResult<OfferModel>> buy(int offerId) => _api.post(
    Endpoints.offers,
    body: BuyOfferRequest(offerId: offerId).toJson(),
    parse: parseObject(OfferModel.fromJson),
  );

  Future<ApiResult<SessionDetailsModel>> session(int id) => _api.get(
    Endpoints.session(id),
    parse: parseObject(SessionDetailsModel.fromJson),
  );
}
