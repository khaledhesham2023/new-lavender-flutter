import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../data/models/responses/offer.dart';
import '../../data/models/responses/speciality.dart';
import '../../data/repositories/offers_repository.dart';
import '../../data/repositories/specialities_repository.dart';

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

/// Port of `OffersViewModel` (offers list part): specialties as tabs, the first
/// one selected, the offers of the selected specialty below.
class OffersCubit extends Cubit<OffersState> {
  OffersCubit(this._specialities, this._offers) : super(const OffersState());

  final SpecialitiesRepository _specialities;
  final OffersRepository _offers;

  Future<void> load() async {
    emit(const OffersState(tabsStatus: ViewStatus.loading));
    final result = await _specialities.getSpecialities();
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(
          state.copyWith(tabsStatus: ViewStatus.success, specialities: data),
        );
        if (data.isEmpty) {
          // Android crashes on `specialties[0]`; show the empty view instead.
          emit(state.copyWith(listStatus: ViewStatus.success));
          return;
        }
        await selectTab(data.first.id);
      case ApiFailure():
        emit(
          state.copyWith(tabsStatus: ViewStatus.failure, tabsFailure: result),
        );
    }
  }

  Future<void> selectTab(int id) async {
    emit(
      state.copyWith(
        selectedId: id,
        listStatus: ViewStatus.loading,
        clearListFailure: true,
      ),
    );
    final result = await _offers.bySpecialty(id);
    // Another tab was tapped while this request was in flight.
    if (isClosed || state.selectedId != id) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(listStatus: ViewStatus.success, offers: data));
      case ApiFailure():
        emit(
          state.copyWith(
            listStatus: ViewStatus.failure,
            listFailure: result,
            offers: const [],
          ),
        );
    }
  }

  /// Pull to refresh: reloads the selected tab (or the tabs when none is).
  Future<void> refresh() {
    final id = state.selectedId;
    return id == null ? load() : selectTab(id);
  }
}
