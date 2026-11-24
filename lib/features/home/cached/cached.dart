import 'package:lavender/data/models/responses/home.dart';
import 'package:lavender/data/models/responses/offer.dart';
import 'package:lavender/l10n/generated/app_localizations.dart';

class Cached {
  static const List<BannerModel> banners = <BannerModel>[
    BannerModel(
      isActive: 0,
      id: 1,
      offerId: 1,
      startDate: '2026-10-01',
      endDate: '2027-10-01',
      image: "https://vectorsarena.com/files/preview/1280x800/15931771918786dtk5uefktgk0wydnaubo6gvdjhqzl0wczmgaf73ie8vaad0mz3lmmjbokt7qitomwj75dqhj4l7ibiil0pswd87ki41hlr61hwvu.jpg",
    ),
    BannerModel(
      isActive: 0,
      id: 1,
      offerId: 1,
      startDate: '2026-10-01',
      endDate: '2027-10-01',
      image: "https://img.magnific.com/free-psd/healthcare-medical-service-ads-promotional-web-banner-template-design_84443-10620.jpg",
    ),
    BannerModel(
      isActive: 0,
      id: 1,
      offerId: 1,
      startDate: '2026-10-01',
      endDate: '2027-10-01',
      image: "https://img.magnific.com/premium-psd/healthcare-medical-service-ads-promotional-web-banner-template-design_84443-10616.jpg",
    ),
  ];

   static List<OfferModel> getOffers(AppLocalizations l10n) {
     return [
       OfferModel(
         id: 102,
         name: l10n.offer_name_1,
         description: l10n.offer_desc_1,
         details: l10n.offer_details_1,
         price: 600.0,
         specialty: l10n.spec_dermatology,
         discount: 25.0,
         finalPrice: 450.0,
         number: 100,
         image: "https://cdn.lahalak.sa/medical-service/cold-peeling-session-for-pigmentation-treatment-6166-sinr.webp",
         usedNumber: 42,
         createdAt: "2026-11-20T08:00:00Z",
         startDate: "2026-11-20T00:00:00Z",
         endDate: "2026-12-31T23:59:59Z",
         appointments: [],
       ),
       OfferModel(
         id: 204,
         name: l10n.offer_name_2,
         description: l10n.offer_desc_2,
         details: l10n.offer_details_2,
         price: 80.0,
         specialty: l10n.spec_dentistry,
         discount: 20.0,
         finalPrice: 40.0,
         number: 150,
         image: "https://img.magnific.com/free-vector/gradient-dental-flyer-template_23-2149336950.jpg",
         usedNumber: 34,
         createdAt: "2026-11-24T09:00:00Z",
         startDate: "2026-11-24T09:00:00Z",
         endDate: "2026-12-31T23:59:59Z",
         appointments: [],
       ),
       OfferModel(
         id: 301,
         name: l10n.offer_name_3,
         description: l10n.offer_desc_3,
         details: l10n.offer_details_3,
         price: 120.0,
         specialty: l10n.spec_dermatology,
         discount: 29,
         finalPrice: 85.0,
         // Starting price (Small Areas)
         number: 3,
         image: "https://medicalweightcontrols.com/cdn/shop/files/Black_Friday_2026_-_1.png",
         usedNumber: 0,
         createdAt: "2026-11-24T09:00:00Z",
         startDate: "2026-11-24T00:00:00Z",
         endDate: "2026-11-25T23:59:59Z",
       ),
     ];
   }
}
