import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/icon_info_box.dart';
import '../../../../data/models/responses/offer.dart';

/// "General info" tab of My offer details (`MyOfferGeneralInfoFragment`):
/// validity period, subscription date, sessions and the details text.
class OfferGeneralInfoTab extends StatelessWidget {
  final OfferModel offer;

  const OfferGeneralInfoTab({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: IconInfoBox(
                    valueSize: 12,
                    labelSize: 11,
                    icon: AppAssets.icOfferCalender,
                    // Kotlin joins the dates with ":" (no spaces).
                    value: '${offer.startDate ?? ''}:${offer.endDate ?? ''}',
                    label: l10n.offerValidityPeriod,
                    labelStart: 12,
                    valueTop: 13,
                  ),
                ),
                const HorizontalSpacer(11),
                Expanded(
                  child: IconInfoBox(
                    valueSize: 12,
                    labelSize: 11,
                    icon: AppAssets.icOfferTicket,
                    value: offer.createdAt ?? '',
                    label: l10n.subscriptionDateNoColon,
                    labelStart: 10,
                    centerValue: true,
                  ),
                ),
              ],
            ),
          ),
          const VerticalSpacer(10),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 5),
                  child: IconInfoBox(
                    valueSize: 12,
                    labelSize: 11,
                    icon: AppAssets.icOfferCalender,
                    // `(number/used)`: the Kotlin argument order.
                    value: l10n.numberOfSessionsWithValue(
                      '${offer.number}',
                      '${offer.usedNumber}',
                    ),
                    label: l10n.numberOfSessionsNoColon,
                    labelStart: 12,
                    valueTop: 13,
                    shrinkValue: true,
                  ),
                ),
              ),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
          const VerticalSpacer(20),
          Text(l10n.details, style: AppTextStyles.bold(14, AppColors.c3D4C5E)),
          const VerticalSpacer(10),
          Text(
            offer.details ?? '',
            style: AppTextStyles.medium(13, AppColors.c3D4C5E),
          ),
        ],
      ),
    );
  }
}
