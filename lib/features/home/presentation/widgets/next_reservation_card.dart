import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../../data/models/responses/home.dart';

/// Whole hours and remaining minutes of [seconds] (Android: `/3600`, `%3600 / 60`).
({int hours, int minutes}) countdownParts(int seconds) =>
    (hours: seconds ~/ 3600, minutes: (seconds % 3600) ~/ 60);

/// Purple "your next reservation" card (`recycler_next_reservation.xml`, `clReservation`).
class NextReservationCard extends StatelessWidget {
  final NextReservationModel reservation;
  final VoidCallback onTap;

  const NextReservationCard({
    super.key,
    required this.reservation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final doctor = reservation.doctor;
    final parts = countdownParts(reservation.difference ?? 0);
    final rate = doctor?.rate;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Android angle 90: start color at the bottom, end color at the top.
          gradient: const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [AppColors.primary, AppColors.c5B2C95, AppColors.c634090],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 16,
                end: 16,
                top: 22,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.yourNextReservation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.semiBold(16, AppColors.white),
                    ),
                  ),
                  _TimeBox(value: parts.hours, label: l10n.hour),
                  const SizedBox(width: 8),
                  _TimeBox(value: parts.minutes, label: l10n.minute),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
              child: Image.asset(
                AppAssets.dashedLineGreyHorizontal,
                width: double.infinity,
                height: 1,
                fit: BoxFit.fill,
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppNetworkImage(
                    url: doctor?.image,
                    width: 69,
                    height: 69,
                    radius: 10,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 69,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor?.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.semiBold(14, AppColors.white),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              StarRating(score: rate ?? 0, size: 11),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  l10n.rateNumberOfReviewsWithValues(
                                    '${rate == null ? null : truncateToDecimal(rate, 1)}',
                                    l10n.reviewsWithNumber(
                                      '${doctor?.reviewsCount}',
                                    ),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.medium(
                                    12,
                                    AppColors.cD9DBE9,
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
                                  doctor?.subSpecialty ?? doctor?.specialty ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.semiBold(
                                    12,
                                    AppColors.cD9DBE9,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

/// `item_hour_min_sec.xml`: translucent value over a white label, 3dp corners.
class _TimeBox extends StatelessWidget {
  final int value;
  final String label;

  const _TimeBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: AppColors.c4DFFFFFF,
              padding: const EdgeInsets.all(2),
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: AppTextStyles.regular(10, AppColors.white),
              ),
            ),
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(2),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.regular(10, AppColors.c656B78),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
