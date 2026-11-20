import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../data/enums/enums.dart';
import 'widgets/filter_options_sheet.dart';

export 'widgets/filter_options_sheet.dart' show FilterSheetResult;

/// Port of `FilterByTypeSheet`: all (`default`), normal (`not_offer`) or offers
/// (`offer`). Resolves like [showFilterByDateSheet]. [current] is the type
/// already applied.
Future<FilterSheetResult<String?>?> showFilterByTypeSheet(
  BuildContext context, {
  String? current,
}) {
  final l10n = context.l10n;
  return showFilterOptionsSheet(
    context,
    title: l10n.filterByType,
    current: current,
    options: [
      FilterOption(AppointmentType.defaultType.value, l10n.allReservations),
      FilterOption(AppointmentType.notOffer.value, l10n.normalReservations),
      FilterOption(AppointmentType.offer.value, l10n.offersReservations),
    ],
  );
}
