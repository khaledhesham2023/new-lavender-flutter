import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/number_utils.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/spacers.dart';
import '../../core/widgets/star_rating.dart';

/// Doctor image / name / brief / rating row shared by the booking and success
/// screens (`cvDoctorImage` + `tvDoctorName` + `tvDoctorBrief` + `crbDoctorRate`
/// + `tvRateAndReviewNumber`). With [bordered] it sits in the grey rounded card
/// used by the success screens.
class DoctorSummaryCard extends StatelessWidget {
  final String? image;
  final String? name;
  final String? brief;
  final double? rate;
  final int? reviewsCount;
  final bool bordered;

  const DoctorSummaryCard({
    super.key,
    this.image,
    this.name,
    this.brief,
    this.rate,
    this.reviewsCount,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final score = rate ?? 0;
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppNetworkImage(
          url: image,
          width: 76,
          height: 76,
          radius: 10,
          fit: BoxFit.fill,
        ),
        const HorizontalSpacer(10),
        Expanded(
          child: SizedBox(
            height: 76,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.semiBold(16, AppColors.c251836),
                ),
                const VerticalSpacer(10),
                Text(
                  brief ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.semiBold(13, AppColors.c666666),
                ),
                const Spacer(),
                Row(
                  children: [
                    StarRating(score: score, size: 11.6),
                    const HorizontalSpacer(4),
                    Flexible(
                      child: Text(
                        l10n.rateNumberOfReviewsWithValues(
                          '${truncateToDecimal(score, 1)}',
                          l10n.reviewsWithNumber('${reviewsCount ?? 0}'),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.semiBold(12, AppColors.c7E94B0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
    if (!bordered) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
        child: row,
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsetsDirectional.fromSTEB(10, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cE6E6E6),
      ),
      child: row,
    );
  }
}
