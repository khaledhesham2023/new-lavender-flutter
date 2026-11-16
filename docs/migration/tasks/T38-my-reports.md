# T38 - My reports

## Goal
Port "Radiology and analysis reports": switch between radiology and laboratory, list grouped by date, download PDFs.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/myreports/screen/MyReportsFragment.kt`, `MyReportsViewModel.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/myreports/adapter/ReportsAdapter.kt`, `ReportsDataAdapter.kt`
- Layouts: `res/layout/fragment_my_reports.xml`, adapter item layouts, `res/color/btn_state_reports.xml`
- `docs/migration/CONTEXT.md` §7.4 (My reports row)
- `lib/core/utils/file_downloader.dart` (T28)

## Build
- `lib/features/reports/my_reports_screen.dart`, `my_reports_cubit.dart`, `widgets/report_day_group.dart`, `widgets/report_item.dart`
- Router: replace `myReports`.

## Steps
1. Cubit: `type` (default radiology) → `ProfileRepository.getReports(type)`; `select(type)` refetches; `refresh()`.
2. Screen: two toggle buttons (radiology / laboratory) styled with `btn_state_reports.xml` (selected/unselected colors); groups with the date header and report rows
   (title, created_at, file icon, download icon). Download (icon or row) → `downloadFile(url: report.file, title: report.title)`.
3. Empty / error views per Kotlin (`observeAllErrors`, empty icon/strings). Pull-to-refresh if the layout has a SwipeRefreshLayout. Back → pop.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: same reports as Android for both types; download saves the file to Downloads with a notification.

## Out of scope
- Opening the report from a notification (T39 routes to this screen).

## Gotchas
- `ReportModel.file` is a full URL.
