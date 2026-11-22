import 'package:equatable/equatable.dart';

import '../../../core/network/api_result.dart';
import '../../../data/models/responses/offer.dart';
import 'my_offers_tab.dart';

class MyOffersState extends Equatable {
  final MyOffersTab tab;
  final ViewStatus status;
  final MyOffersData? data;
  final ApiFailure<dynamic>? failure;

  const MyOffersState({
    this.tab = MyOffersTab.valid,
    this.status = ViewStatus.initial,
    this.data,
    this.failure,
  });

  /// The offers of the selected tab.
  List<OfferModel> get offers {
    final d = data;
    if (d == null) return const [];
    return tab == MyOffersTab.valid ? d.availableOffers : d.completedOffers;
  }

  @override
  List<Object?> get props => [tab, status, data, failure];
}
