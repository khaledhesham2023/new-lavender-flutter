import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/spacers.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../../data/models/responses/doctor.dart';

/// Port of `ReviewsAdapter` / `recycler_item_review.xml`: avatar, name, date,
/// stars and comment on a light grey card.
class ReviewItem extends StatelessWidget {
  final ReviewModel review;

  const ReviewItem({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 25),
      color: AppColors.cFAFAFA,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppNetworkImage(
                url: review.clientImage,
                width: 36,
                height: 36,
                circle: true,
              ),
              const HorizontalSpacer(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.clientName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.semiBold(12, AppColors.c090B0E),
                    ),
                    const VerticalSpacer(6),
                    Text(
                      review.date == null
                          ? ''
                          : formatToLongDate(review.date!, lang),
                      style: AppTextStyles.regular(12, AppColors.c546881),
                    ),
                  ],
                ),
              ),
              StarRating(score: review.rate ?? 0, size: 11.8),
            ],
          ),
          const VerticalSpacer(10),
          Text(
            review.comment ?? '',
            style: AppTextStyles.regular(12, AppColors.c090B0E),
          ),
        ],
      ),
    );
  }
}
