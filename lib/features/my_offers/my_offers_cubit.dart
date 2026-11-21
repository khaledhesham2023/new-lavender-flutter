import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../data/models/responses/offer.dart';
import '../../data/repositories/offers_repository.dart';

/// The Valid / Completed toggle (`OfferType`).
enum MyOffersTab { valid, completed }

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

/// Port of the `GetMyOffers` event of `OffersViewModel` as used by `MyOffersFragment`:
/// one `myOffers()` call whose answer holds both lists; the toggle picks one and,
/// like Android, calls the API again on every change.
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
