import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/number_utils.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/info_tile.dart';
import '../../../core/widgets/spacers.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../data/models/responses/doctor.dart';
import 'favorite_button.dart';

/// Doctor card (`recycler_item_doctor.xml`). The heart shows only when
/// [onFavorite] is set (logged-in users). Reused by T20 / T30.
class DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final double width;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
    this.onFavorite,
    this.width = 319,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rate = doctor.rate;
    final price = double.tryParse(doctor.price ?? '');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cE6E6E6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 10,
                end: 10,
                top: 16,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppNetworkImage(
                    url: doctor.image,
                    width: 71,
                    height: 71,
                    radius: 10,
                    fit: BoxFit.fill,
                  ),
                  const HorizontalSpacer(10),
                  Expanded(
                    child: SizedBox(
                      height: 71,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.semiBold(14),
                          ),
                          const VerticalSpacer(8),
                          Row(
                            children: [
                              StarRating(score: rate ?? 0, size: 11),
                              const HorizontalSpacer(2),
                              Flexible(
                                child: Text(
                                  l10n.rateNumberOfReviewsWithValues(
                                    '${rate == null ? null : truncateToDecimal(rate, 1)}',
                                    l10n.reviewsWithNumber(
                                      '${doctor.reviewsCount}',
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
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  doctor.subSpecialty ?? doctor.specialty ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.semiBold(
                                    13,
                                    AppColors.c3D4C5E,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (onFavorite != null)
                    FavoriteButton(isFav: doctor.isFav, onTap: onFavorite!),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 26, 10, 16),
              child: Row(
                children: [
                  Expanded(
                    child: InfoTile(
                      label: l10n.examinationDuration,
                      value: l10n.minValues('${doctor.duration}'),
                    ),
                  ),
                  const HorizontalSpacer(11),
                  Expanded(
                    child: InfoTile(
                      label: l10n.examinationPrice,
                      value: l10n.priceWithValue(formatDecimal(price)),
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
