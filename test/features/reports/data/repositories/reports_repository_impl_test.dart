import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/core/enums/enums.dart';
import 'package:lavender/data/models/responses/report.dart';
import 'package:lavender/features/reports/data/repositories/reports_repository_impl.dart';

import '../../../../data/repositories/fake_api.dart';

void main() {
  test('getReports sends type and parses days', () async {
    final (api, a) = await makeApi(
      body: {
        'data': [
          {
            'date': '2024-01-01',
            'reports': [
              {'id': 1, 'title': 'T'},
            ],
          },
        ],
      },
    );
    final r = await ReportsRepositoryImpl(api)
        .getReports(ReportType.laboratory);
    expect(a.method, 'GET');
    expect(a.path, 'client/my-reports');
    expect(a.query, {'type': 'laboratory'});
    final days = (r as ApiSuccess<List<DayReportsModel>>).data;
    expect(days.single.reports.single.id, 1);
  });

  test('getReports with empty or missing data returns []', () async {
    for (final body in [
      {'data': []},
      {'message': 'none'},
    ]) {
      final (api, _) = await makeApi(body: body);
      final r = await ReportsRepositoryImpl(api)
          .getReports(ReportType.radiology);
      expect(r, isA<ApiSuccess<List<DayReportsModel>>>());
      expect((r as ApiSuccess<List<DayReportsModel>>).data, isEmpty);
    }
  });
}
