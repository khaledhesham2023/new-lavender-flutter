import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/spacers.dart';
import '../../../../data/models/responses/offer.dart';
import '../../../../shared/widgets/discount_badge.dart';

/// Kotlin `Float.toString()` as shown by the list item prices (`220.0`, `138.5`).
String kotlinFloatString(double? v) {
  if (v == null) return 'null';
  return v == v.truncateToDouble() ? v.toStringAsFixed(1) : v.toString();
}

/// Offers list item (`recycler_item_offer.xml` + `OffersAdapter`): 241dp card.
class OfferCard extends StatelessWidget {
  final OfferModel offer;
  final VoidCallback onTap;

  const OfferCard({super.key, required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 241,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cFAFAFA,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: AppNetworkImage(
                    url: offer.image,
                    radius: 10,
                    fit: BoxFit.fill,
                  ),
                ),
                const VerticalSpacer(12),
                Text(
                  offer.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.semiBold(14),
                ),
                const VerticalSpacer(8),
                Text(
                  offer.description ?? '',
                  style: AppTextStyles.semiBold(12, AppColors.c666666),
                ),
                const VerticalSpacer(12),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 10),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          l10n.priceWithValue(kotlinFloatString(offer.price)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.semiBold(
                            13,
                            AppColors.c7E94B0,
                          ).copyWith(decoration: TextDecoration.lineThrough),
                        ),
                      ),
                      const HorizontalSpacer(6),
                      Flexible(
                        child: Text(
                          l10n.priceWithValue(
                            kotlinFloatString(offer.finalPrice),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bold(16, AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            PositionedDirectional(
              end: 10,
              top: 10,
              child: DiscountBadge(
                discount: offer.discount,
                boldLabel: true,
                valueBias: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
