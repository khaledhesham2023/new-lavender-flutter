import 'package:equatable/equatable.dart';
import '../../../core/network/api_result.dart';
import '../../../data/models/responses/offer.dart';
import '../../../data/models/responses/speciality.dart';

class OffersState extends Equatable {
  /// Whole-screen status of the specialty tabs request.
  final ViewStatus tabsStatus;
  final ApiFailure<dynamic>? tabsFailure;
  final List<SpecialityModel> specialities;
  final int? selectedId;

  /// Status of the offers list under the tabs.
  final ViewStatus listStatus;
  final ApiFailure<dynamic>? listFailure;
  final List<OfferModel> offers;

  const OffersState({
    this.tabsStatus = ViewStatus.initial,
    this.tabsFailure,
    this.specialities = const [],
    this.selectedId,
    this.listStatus = ViewStatus.initial,
    this.listFailure,
    this.offers = const [],
  });

  OffersState copyWith({
    ViewStatus? tabsStatus,
    ApiFailure<dynamic>? tabsFailure,
    List<SpecialityModel>? specialities,
    int? selectedId,
    ViewStatus? listStatus,
    ApiFailure<dynamic>? listFailure,
    bool clearListFailure = false,
    List<OfferModel>? offers,
  }) {
    return OffersState(
      tabsStatus: tabsStatus ?? this.tabsStatus,
      tabsFailure: tabsFailure ?? this.tabsFailure,
      specialities: specialities ?? this.specialities,
      selectedId: selectedId ?? this.selectedId,
      listStatus: listStatus ?? this.listStatus,
      listFailure: clearListFailure ? null : (listFailure ?? this.listFailure),
      offers: offers ?? this.offers,
    );
  }

  @override
  List<Object?> get props => [
    tabsStatus,
    tabsFailure,
    specialities,
    selectedId,
    listStatus,
    listFailure,
    offers,
  ];
}
