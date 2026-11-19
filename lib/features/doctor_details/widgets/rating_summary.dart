import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/number_utils.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../core/widgets/spacers.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../data/models/responses/doctor.dart';

/// Big rate, stars, "based on n reviews", the dashed separator and the five
/// animated bars (5 -> 1) of `fragment_reviews.xml`.
class RatingSummary extends StatelessWidget {
  final DoctorModel doctor;

  const RatingSummary({super.key, required this.doctor});

  /// `((countN ?? 0) / reviews.length * 100).toInt()`.
  static int percentOf(double? count, int total) {
    if (total == 0) return 0;
    return ((count ?? 0) / total * 100).toInt().clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = doctor.reviews.length;
    final bars = [
      (5, doctor.five, AppColors.c03A853),
      (4, doctor.four, AppColors.c50C878),
      (3, doctor.three, AppColors.cFFC107),
      (2, doctor.two, AppColors.cDC8151),
      (1, doctor.one, AppColors.cC54B4B),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 106,
          child: Column(
            children: [
              const VerticalSpacer(20),
              Text(
                '${truncateToDecimal(doctor.rate ?? 0, 1)}',
                style: AppTextStyles.bold(26, AppColors.black),
              ),
              const VerticalSpacer(8),
              StarRating(score: doctor.stars ?? 0, size: 19.6),
              const VerticalSpacer(8),
              Text(
                l10n.basedOnNoOfReviews('${doctor.reviewsCount ?? 0}'),
                textAlign: TextAlign.center,
                style: AppTextStyles.medium(10, AppColors.c60717F),
              ),
            ],
          ),
        ),
        const HorizontalSpacer(33),
        Padding(
          padding: const EdgeInsets.only(top: 11),
          child: Image.asset(
            AppAssets.dashedLineGreyVertical,
            height: 101,
            fit: BoxFit.fill,
          ),
        ),
        const HorizontalSpacer(33),
        Expanded(
          child: Column(
            children: [
              for (var i = 0; i < bars.length; i++) ...[
                if (i > 0) const VerticalSpacer(11),
                _RatingBar(
                  stars: bars[i].$1,
                  percent: percentOf(bars[i].$2, total),
                  color: bars[i].$3,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RatingBar extends StatelessWidget {
  final int stars;
  final int percent;
  final Color color;

  const _RatingBar({
    required this.stars,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppSvg(AppAssets.icStar, width: 10, height: 10, color: color),
        const HorizontalSpacer(2),
        Text('$stars', style: AppTextStyles.semiBold(12, AppColors.c99000000)),
        const HorizontalSpacer(4),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent / 100),
            duration: const Duration(milliseconds: 2500),
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 4,
                color: color,
                backgroundColor: AppColors.cE7E7E7,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
