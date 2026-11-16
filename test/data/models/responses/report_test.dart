import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/data/models/responses/report.dart';

void main() {
  test('DayReportsModel parses reports', () {
    final d = DayReportsModel.fromJson({
      'date': '2024-05-01',
      'reports': [
        {
          'id': '1',
          'file': 'http://x/r.pdf',
          'title': 'CBC',
          'type': 'laboratory',
          'created_at': '2024-05-01',
        },
        {'id': 2},
      ],
    });
    expect(d.date, '2024-05-01');
    expect(d.reports.length, 2);
    expect(d.reports[0].id, 1);
    expect(d.reports[0].type, 'laboratory');
    expect(d.reports[1].file, isNull);
  });

  test('null reports list', () {
    expect(DayReportsModel.fromJson({'reports': null}).reports, isEmpty);
  });
}
