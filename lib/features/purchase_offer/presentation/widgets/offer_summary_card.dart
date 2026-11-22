import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../data/models/responses/offer.dart';

/// `clOfferData` of the purchase and success layouts: the 87x89 image with the
/// offer name, brief and the old (struck) and final price.
class OfferSummaryCard extends StatelessWidget {
  final OfferModel offer;

  const OfferSummaryCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsetsDirectional.only(start: 16, top: 16, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppNetworkImage(
            url: offer.image,
            width: 87,
            height: 89,
            radius: 10,
            fit: BoxFit.fill,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 10, end: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.semiBold(14, AppColors.c251836),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      offer.description ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.semiBold(12, AppColors.c666666),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            l10n.priceWithValue(formatDecimal(offer.price)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.semiBold(13, AppColors.c7E94B0)
                                .copyWith(
                                  decoration: TextDecoration.lineThrough,
                                ),
                          ),
                        ),
                        const HorizontalSpacer(6),
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
