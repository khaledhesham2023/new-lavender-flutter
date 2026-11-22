import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../shared/domain/repositories/offers_repository.dart';
import '../../../shared/domain/repositories/specialities_repository.dart';
import 'offers_state.dart';

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
