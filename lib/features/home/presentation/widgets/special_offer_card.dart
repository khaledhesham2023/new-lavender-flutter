import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_svg.dart';
import '../../../../data/models/responses/offer.dart';

/// Offer card (`recycler_item_special_offer.xml`). Reused by the offers list (T18).
class SpecialOfferCard extends StatelessWidget {
  final OfferModel offer;
  final VoidCallback onTap;

  const SpecialOfferCard({super.key, required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    // The Android layout rotates the label and the value independently.
    final labelAngle = (isEn ? 10 : -10) * math.pi / 180;
    final valueAngle = (isAr ? -10 : 10) * math.pi / 180;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: AppColors.cFAFAFA,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 240,
              height: 130,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AppNetworkImage(
                      url: offer.image,
                      radius: 10,
                      fit: BoxFit.cover,
                    ),
                  ),
                  PositionedDirectional(
                    end: 10,
                    top: 10,
                    child: SizedBox(
                      width: 63,
                      height: 55,
                      child: Stack(
                        children: [
                          const Positioned.fill(
                            child: AppSvg(AppAssets.bgDiscount),
                          ),
                          Align(
                            alignment: const Alignment(0, -0.4),
                            child: Transform.rotate(
                              angle: labelAngle,
                              child: Text(
                                l10n.off,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.medium(12, AppColors.white),
                              ),
                            ),
                          ),
                          Align(
                            alignment: const Alignment(0, 0.3),
                            child: Transform.rotate(
                              angle: valueAngle,
                              child: Text(
                                formatPercentage(offer.discount),
                                style: AppTextStyles.discount(
                                  12,
                                  AppColors.white,
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
            const SizedBox(height: 12),
            Text(
              offer.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.semiBold(14),
            ),
            const SizedBox(height: 8),
            Text(
              offer.description ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.semiBold(12, AppColors.c666666),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                  child: Text(
                    l10n.priceWithValue(formatDecimal(offer.price)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.semiBold(13, AppColors.c7E94B0)
                        .copyWith(decoration: TextDecoration.lineThrough),
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: Text(
                    l10n.priceWithValue(formatDecimal(offer.finalPrice)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bold(16, AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
