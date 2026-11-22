import '../../../../core/enums/enums.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../data/json/json_utils.dart';
import '../../../../data/models/responses/report.dart';
import '../../domain/repositories/reports_repository.dart';

/// [ReportsRepository] over the Lavender API.
class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<ApiResult<List<DayReportsModel>>> getReports(ReportType type) =>
      _api.call(
        (s) => s.myReports(type.value),
        parse: (j) => asList(asMap(j)?['data'], DayReportsModel.fromJson),
      );
}
