import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/number_utils.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/info_tile.dart';
import '../../../core/widgets/spacers.dart';
import '../../../data/models/responses/offer.dart';

/// Item of the My offers list (`recycler_item_my_offers.xml` + `MyOffersAdapter`).
class MyOfferCard extends StatelessWidget {
  final OfferModel offer;
  final VoidCallback onTap;

  const MyOfferCard({super.key, required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cE6E6E6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 10, top: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppNetworkImage(
                    url: offer.image,
                    width: 87,
                    height: 87,
                    radius: 10,
                    fit: BoxFit.fill,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 10,
                        end: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.semiBold(14),
                          ),
                          const VerticalSpacer(8),
                          Text(
                            offer.description ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.semiBold(
                              12,
                              AppColors.c666666,
                            ),
                          ),
                          const VerticalSpacer(8),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  l10n.priceWithValue(
                                    formatDecimal(offer.price),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      AppTextStyles.semiBold(
                                        13,
                                        AppColors.c7E94B0,
                                      ).copyWith(
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                ),
                              ),
                              const HorizontalSpacer(6),
                              Flexible(
                                child: Text(
                                  l10n.priceWithValue(
                                    formatDecimal(offer.finalPrice),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bold(
                                    16,
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
              child: Row(
                children: [
                  Expanded(
                    child: InfoTile(
                      labelGap: 2,
                      horizontalPadding: 5,
                      label: l10n.numberOfSessions,
                      value: l10n.numberOfSessionsWithValue(
                        '${offer.number}',
                        '${offer.usedNumber}',
                      ),
                    ),
                  ),
                  const HorizontalSpacer(11),
                  Expanded(
                    child: InfoTile(
                      labelGap: 2,
                      horizontalPadding: 5,
                      label: l10n.subscriptionDate,
                      value: offer.createdAt ?? '',
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
