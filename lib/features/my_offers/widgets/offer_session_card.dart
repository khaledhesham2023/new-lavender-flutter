import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/number_utils.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/enums/enums.dart';
import '../../../data/models/responses/appointment.dart';
import '../../appointment_details/widgets/status_pill.dart';
import '../ordinal.dart';

/// Booking of an offer (`recycler_item_offer_bookings.xml` + `MyOfferBookingsAdapter`).
/// [position] is the zero-based index: a completed booking is named after it
/// ("Session first", "Session second", ...).
class OfferSessionCard extends StatelessWidget {
  final AppointmentData item;
  final int position;
  final VoidCallback onTap;

  const OfferSessionCard({
    super.key,
    required this.item,
    required this.position,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final status = BookingStatus.fromValue(item.status);
    final (background, foreground) = statusPillColors(status);
    final pillText = status == BookingStatus.completed
        ? l10n.sessionWithValue(numberToOrdinalWord(position + 1, lang))
        : item.statusTrans ?? '';
    final doctor = item.doctor;
    final rate = doctor?.rate;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cE6E6E6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 10,
                      end: 10,
                      top: 25,
                    ),
                    child: Text(
                      item.formatedDate ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.semiBold(13, AppColors.c251836),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10, top: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      pillText,
                      style: AppTextStyles.bold(12, foreground),
                    ),
                  ),
                ),
              ],
            ),
            const VerticalSpacer(14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Image.asset(
                AppAssets.dashedLineGreyHorizontal2,
                height: 1,
                fit: BoxFit.fill,
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 10,
                end: 10,
                top: 14,
                bottom: 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppNetworkImage(
                    url: doctor?.image,
                    width: 69,
                    height: 69,
                    radius: 10,
                    fit: BoxFit.fill,
                  ),
                  const HorizontalSpacer(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor?.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.semiBold(14, AppColors.c251836),
                        ),
                        const VerticalSpacer(8),
                        Row(
                          children: [
                            StarRating(score: rate ?? 0, size: 11.6),
                            const HorizontalSpacer(22),
                            Flexible(
                              child: Text(
                                l10n.rateNumberOfReviewsWithValues(
                                  '${truncateToDecimal(rate ?? 0, 1)}',
                                  l10n.reviewsWithNumber(
                                    '${doctor?.reviewsCount ?? 0}',
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.semiBold(
                                  12,
                                  AppColors.c7E94B0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const VerticalSpacer(8),
                        Text(
                          doctor?.subSpecialty ?? doctor?.specialty ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.semiBold(13, AppColors.c3D4C5E),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
