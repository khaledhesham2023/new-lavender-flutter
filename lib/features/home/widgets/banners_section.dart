import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/spacers.dart';
import '../../../data/models/responses/home.dart';

/// Horizontal list of offer banners (`recycler_item_banners.xml` + `recycler_offer_item.xml`).
class BannersSection extends StatelessWidget {
  final List<BannerModel> banners;
  final ValueChanged<BannerModel> onTap;

  const BannersSection({super.key, required this.banners, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: SizedBox(
        height: 160,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsetsDirectional.only(start: 16),
          itemCount: banners.length,
          separatorBuilder: (_, _) => const HorizontalSpacer(12),
          itemBuilder: (context, i) {
            final banner = banners[i];
            return GestureDetector(
              onTap: () => onTap(banner),
              child: AppNetworkImage(
                url: banner.image,
                width: 315,
                height: 160,
                radius: 16,
                fit: BoxFit.fill,
              ),
            );
          },
        ),
      ),
    );
  }
}
