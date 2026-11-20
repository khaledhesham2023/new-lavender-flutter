import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n_ext.dart';
import 'widgets/filter_options_sheet.dart';

export 'widgets/filter_options_sheet.dart' show FilterSheetResult;

/// Port of `FilterByDateSheet`: last 3 / 6 / 12 months. Resolves to a
/// [FilterSheetResult] holding `"3"`, `"6"`, `"12"` or null (remove all), or to
/// null when dismissed. [current] is the month already applied.
Future<FilterSheetResult<String?>?> showFilterByDateSheet(
  BuildContext context, {
  String? current,
}) {
  final l10n = context.l10n;
  return showFilterOptionsSheet(
    context,
    title: l10n.filterByDate,
    current: current,
    options: [
      FilterOption('3', l10n.last3Months),
      FilterOption('6', l10n.last6Months),
      FilterOption('12', l10n.last12Months),
    ],
  );
}
