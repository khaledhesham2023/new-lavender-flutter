import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/spacers.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../../data/models/responses/doctor.dart';
import 'rating_summary.dart';
import 'review_item.dart';

/// Port of `ReviewsFragment`: empty state, or the rating summary plus the list.
class ReviewsTab extends StatelessWidget {
  final DoctorModel doctor;

  const ReviewsTab({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reviews = doctor.reviews;
    final titleStyle = AppTextStyles.bold(14, AppColors.c3D4C5E);
    if (reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 21, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reviews, style: titleStyle),
            Expanded(
              child: StateView.empty(
                icon: AppAssets.icNoReviews,
                title: l10n.noReviews,
              ),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const VerticalSpacer(21),
          Text(l10n.ratesWithValue('(${reviews.length})'), style: titleStyle),
          const VerticalSpacer(10),
          RatingSummary(doctor: doctor),
          const VerticalSpacer(14),
          const Divider(height: 1, thickness: 1, color: AppColors.cE6E6E6),
          const VerticalSpacer(14),
          for (final review in reviews) ReviewItem(review: review),
        ],
      ),
    );
  }
}
