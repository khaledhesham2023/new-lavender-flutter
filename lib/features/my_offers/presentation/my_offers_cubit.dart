import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../shared/domain/repositories/offers_repository.dart';
import 'my_offers_state.dart';
import 'my_offers_tab.dart';

class MyOffersCubit extends Cubit<MyOffersState> {
  MyOffersCubit(this._repository) : super(const MyOffersState());

  final OffersRepository _repository;

  Future<void> load() async {
    emit(
      MyOffersState(
        tab: state.tab,
        status: ViewStatus.loading,
        data: state.data,
      ),
    );
    final result = await _repository.myOffers();
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(
          MyOffersState(tab: state.tab, status: ViewStatus.success, data: data),
        );
      case ApiFailure():
        emit(
          MyOffersState(
            tab: state.tab,
            status: ViewStatus.failure,
            failure: result,
          ),
        );
    }
  }

  /// Switching the toggle refetches (the same tab does nothing).
  void selectTab(MyOffersTab tab) {
    if (tab == state.tab) return;
    emit(MyOffersState(tab: tab, status: state.status, data: state.data));
    load();
  }
}
