import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../core/enums/enums.dart';
import '../domain/repositories/reports_repository.dart';
import 'my_reports_state.dart';

/// Port of `MyReportsViewModel` (`GetReportsByState`): radiology by default,
/// every toggle change and pull-to-refresh requests the list again.
class MyReportsCubit extends Cubit<MyReportsState> {
  MyReportsCubit(this._repository) : super(const MyReportsState());

  final ReportsRepository _repository;

  Future<void> load() async {
    final type = state.type;
    emit(MyReportsState(type: type, status: ViewStatus.loading));
    final result = await _repository.getReports(type);
    if (isClosed || type != state.type) return; // a newer toggle won
    switch (result) {
      case ApiSuccess(:final data):
        emit(
          MyReportsState(type: type, status: ViewStatus.success, days: data),
        );
      case ApiFailure():
        emit(
          MyReportsState(
            type: type,
            status: ViewStatus.failure,
            failure: result,
          ),
        );
    }
  }

  /// Pull-to-refresh (Android `swipeRefreshLayout`): same request as [load].
  Future<void> refresh() => load();

  void select(ReportType type) {
    if (type == state.type) return;
    emit(MyReportsState(type: type, status: ViewStatus.loading));
    load();
  }
}
