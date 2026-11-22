import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/app/di/injection.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/core/enums/enums.dart';
import 'package:lavender/data/models/responses/report.dart';
import 'package:lavender/features/reports/domain/repositories/reports_repository.dart';
import 'package:lavender/features/reports/presentation/my_reports_screen.dart';
import 'package:lavender/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class _FakeProfile implements ReportsRepository {
  final List<ReportType> asked = [];
  Map<ReportType, List<DayReportsModel>> data = {
    ReportType.radiology: [
      const DayReportsModel(
        date: '1 Jan',
        reports: [
          ReportModel(id: 1, title: 'Chest CT'),
          ReportModel(id: 2, title: 'Knee MRI'),
        ],
      ),
    ],
    ReportType.laboratory: [],
  };

  @override
  Future<ApiResult<List<DayReportsModel>>> getReports(ReportType type) async {
    asked.add(type);
    return ApiSuccess(data[type]!);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _host() => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: const MyReportsScreen(),
);

void main() {
  testWidgets('radiology list is grouped by date, laboratory is empty', (
    t,
  ) async {
    final repo = _FakeProfile();
    await sl.reset();
    sl.registerSingleton<ReportsRepository>(repo);
    await t.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(_host());
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));

    expect(find.text('My Reports'), findsOneWidget);
    expect(find.text('1 Jan'), findsOneWidget);
    expect(find.text('Chest CT'), findsOneWidget);
    expect(find.text('Knee MRI'), findsOneWidget);

    await t.tap(find.text('Laboratory'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    expect(repo.asked, [ReportType.radiology, ReportType.laboratory]);
    expect(find.text('You have no reports'), findsOneWidget);
    expect(find.text('Chest CT'), findsNothing);
  });
}
