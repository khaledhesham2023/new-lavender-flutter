import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/responses/report.dart';
import 'report_item.dart';

/// `recycler_item_my_reports`: the date header and that day's report cards.
class ReportDayGroup extends StatelessWidget {
  final DayReportsModel day;
  final ValueChanged<ReportModel> onDownload;

  const ReportDayGroup({
    super.key,
    required this.day,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            day.date ?? '',
            style: AppTextStyles.bold(14, AppColors.c3D4C5E),
          ),
          for (final report in day.reports)
            ReportItem(report: report, onDownload: () => onDownload(report)),
        ],
      ),
    );
  }
}
