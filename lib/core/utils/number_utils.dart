import 'package:intl/intl.dart';

// Ports of the number helpers (ViewExtFunctions.kt). Callers wrap the result with
// `l10n.priceWithValue` / `l10n.sar` where Android did.

// Grouping, max 3 fraction digits: same as Java NumberFormat.getInstance(ENGLISH).
final NumberFormat _en = NumberFormat.decimalPattern('en');

/// English-digit decimal: `150.0` -> `150`, `150.5` -> `150.5`, `1500` -> `1,500`,
/// null -> ''. (Android `formatDecimalNumber`.)
String formatDecimal(num? n) => n == null ? '' : _en.format(n);

/// [formatDecimal] followed by `%` (Android `formatPercentageNumber`).
String formatPercentage(num? n) => n == null ? '' : '${formatDecimal(n)}%';

/// Truncates (does not round) to [places] decimals: `4.68, 1` -> `4.6`.
double truncateToDecimal(double v, int places) {
  var factor = 1.0;
  for (var i = 0; i < places; i++) {
    factor *= 10;
  }
  return (v * factor).truncate() / factor;
}

/// `"150.0"` -> `"150"`, `"150.5"` -> `"150.5"`, non-numbers unchanged.
String formatDecimalString(String? s) {
  if (s == null) return '';
  final n = double.tryParse(s);
  if (n == null) return s;
  return n % 1 == 0 ? n.toInt().toString() : n.toString();
}
