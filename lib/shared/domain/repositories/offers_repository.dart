import '../../../core/network/api_result.dart';
import '../../../data/models/responses/offer.dart';

/// Offers, the user's offers and offer sessions, used by offers, my_offers,
/// purchase_offer, booking and session_details. `OffersRepositoryImpl`
/// (shared data layer) implements it.
abstract interface class OffersRepository {
  Future<ApiResult<List<OfferModel>>> bySpecialty(int id);

  Future<ApiResult<OfferModel>> details(int id);

  Future<ApiResult<MyOffersData>> myOffers();

  Future<ApiResult<OfferModel>> myOfferDetails(int id);

  /// Called after a successful payment; returns the purchased (user) offer.
  Future<ApiResult<OfferModel>> buy(int offerId);

  Future<ApiResult<SessionDetailsModel>> session(int id);
}
