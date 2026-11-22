import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_svg.dart';
import '../../../../data/models/responses/report.dart';

/// `recycler_item_report`: a 57-high outlined card with the PDF icon, the title
/// and the download icon. Tapping anywhere downloads (the row forwards to the icon).
class ReportItem extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onDownload;

  const ReportItem({super.key, required this.report, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.cE0E0E0),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onDownload,
          child: SizedBox(
            height: 57,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const AppSvg(AppAssets.icPdf),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        report.title ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.semiBold(12, AppColors.c10162E),
                      ),
                    ),
                  ),
                  const AppSvg(AppAssets.icDownload),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
