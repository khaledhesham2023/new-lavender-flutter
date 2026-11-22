import 'package:equatable/equatable.dart';
import '../../../core/network/api_result.dart';
import '../../../core/enums/enums.dart';
import '../../../data/models/responses/report.dart';

class MyReportsState extends Equatable {
  final ReportType type;
  final ViewStatus status;
  final List<DayReportsModel> days;
  final ApiFailure<dynamic>? failure;

  const MyReportsState({
    this.type = ReportType.radiology,
    this.status = ViewStatus.initial,
    this.days = const [],
    this.failure,
  });

  /// Android shows the empty view when the list of days is empty.
  bool get isEmpty => days.isEmpty;

  @override
  List<Object?> get props => [type, status, days, failure];
}
