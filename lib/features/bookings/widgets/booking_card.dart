import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/number_utils.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../data/enums/enums.dart';
import '../../../data/models/responses/appointment.dart';

/// Booking card (`recycler_item_booking.xml` + `BookingsAdapter`). The buttons
/// depend on the item's own status. The callbacks receive the item, which
/// carries its id, status, doctor and offer (T27 needs them).
class BookingCard extends StatelessWidget {
  final AppointmentData item;
  final VoidCallback onTap;
  final ValueChanged<AppointmentData> onCancel;
  final ValueChanged<AppointmentData> onEdit;
  final ValueChanged<AppointmentData> onRate;
  final ValueChanged<AppointmentData> onRebook;

  const BookingCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onCancel,
    required this.onEdit,
    required this.onRate,
    required this.onRebook,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final status = BookingStatus.fromValue(item.status);
    final doctor = item.doctor;
    final rate = doctor?.rate;
    final from = item.from;
    final time = '${item.formatedDate ?? ''} - '
        '${from == null ? '' : convertTo24HourTime(from, lang)}';
    final hasBadge = item.offer != null;

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
          mainAxisSize: MainAxisSize.min,
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
                      time,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.semiBold(13, AppColors.c251836),
                    ),
                  ),
                ),
                if (hasBadge)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 10, top: 16),
                    child: _OfferBadge(status: status),
                  ),
              ],
            ),
            // The Android separator sits 23dp under the date text; the badge
            // (when shown) already covers part of that distance.
            SizedBox(height: hasBadge ? 13 : 23),
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
                  const SizedBox(width: 10),
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
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            StarRating(score: rate ?? 0, size: 11.6),
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
                                style: AppTextStyles.semiBold(
                                  12,
                                  AppColors.c7E94B0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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
            if (_buttons(context, status) case final buttons?)
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 10,
                  end: 10,
                  top: 20,
                  bottom: 16,
                ),
                child: buttons,
              )
            else
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget? _buttons(BuildContext context, BookingStatus? status) {
    final l10n = context.l10n;
    switch (status) {
      case BookingStatus.pending:
      case BookingStatus.confirmed:
        return Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: l10n.editBooking,
                filled: true,
                enabled: item.canReschedule,
                onTap: () => onEdit(item),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                label: l10n.cancelBooking,
                onTap: () => onCancel(item),
              ),
            ),
          ],
        );
      case BookingStatus.completed:
        final reviewed = item.isReviewed;
        return Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: reviewed ? l10n.reviewed : l10n.rateBooking,
                filled: true,
                // `isEnabled = !is_reviewed`; the primary fill stays as in XML.
                keepFillWhenDisabled: true,
                enabled: !reviewed,
                icon: reviewed
                    ? AppAssets.icRateStarSolidWhite
                    : AppAssets.icRateStarWhite,
                onTap: () => onRate(item),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                label: l10n.rebook,
                onTap: () => onRebook(item),
              ),
            ),
          ],
        );
      case BookingStatus.canceled:
      case BookingStatus.rejected:
        return _ActionButton(label: l10n.rebook, onTap: () => onRebook(item));
      case BookingStatus.processing:
        // Android: the button just performs a click on the whole card.
        return _ActionButton(
          label: l10n.showDetails,
          filled: true,
          onTap: onTap,
        );
      case null:
        return null;
    }
  }
}

/// 46dp-high rounded button: primary-filled or primary-outlined; grey when a
/// filled one is disabled. The label shrinks (14 -> 10) like `autoSizeText`.
class _ActionButton extends StatelessWidget {
  final String label;
  final bool filled;
  final bool enabled;
  final bool keepFillWhenDisabled;
  final String? icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.onTap,
    this.filled = false,
    this.enabled = true,
    this.keepFillWhenDisabled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final Color background;
    if (!filled) {
      background = AppColors.white;
    } else if (enabled || keepFillWhenDisabled) {
      background = AppColors.primary;
    } else {
      background = AppColors.cBEBEBE;
    }
    final textColor = filled ? AppColors.white : AppColors.primary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: AppColors.primary),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                AppSvg(icon!),
                const SizedBox(width: 2),
              ],
              Text(
                label,
                maxLines: 1,
                style: AppTextStyles.semiBold(14, textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Offer" chip shown when the booking belongs to an offer; its colors follow
/// the status (`tvStatus` in `BookingsAdapter`).
class _OfferBadge extends StatelessWidget {
  final BookingStatus? status;

  const _OfferBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground) = switch (status) {
      BookingStatus.pending => (AppColors.cF8F6FA, AppColors.primary),
      BookingStatus.confirmed => (AppColors.cE6E6E6, AppColors.c251836),
      BookingStatus.completed => (AppColors.c1950C878, AppColors.c50C878),
      BookingStatus.canceled ||
      BookingStatus.rejected => (AppColors.c19ED1C24, AppColors.cED1C24),
      BookingStatus.processing => (AppColors.cF8FAFB, AppColors.c006F98),
      null => (AppColors.white, AppColors.primary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvg(AppAssets.icDiscountBooking, color: foreground),
          const SizedBox(width: 2),
          Text(
            context.l10n.offer,
            style: AppTextStyles.bold(12, foreground),
          ),
        ],
      ),
    );
  }
}
