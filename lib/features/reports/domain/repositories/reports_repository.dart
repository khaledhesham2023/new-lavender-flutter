import '../../../../core/enums/enums.dart';
import '../../../../core/network/api_result.dart';
import '../../../../data/models/responses/report.dart';

/// The user's medical reports, used by the reports feature.
/// `ReportsRepositoryImpl` (data layer) implements it.
abstract interface class ReportsRepository {
  /// A missing or empty `data` gives an empty list, not a failure.
  Future<ApiResult<List<DayReportsModel>>> getReports(ReportType type);
}
