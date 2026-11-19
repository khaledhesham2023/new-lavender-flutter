import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/spacers.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../data/models/responses/speciality.dart';

/// `layout_most_popular.xml`: title and one row per most-selected speciality.
class MostSelectedList extends StatelessWidget {
  final List<SpecialityModel> items;
  final ValueChanged<SpecialityModel> onTap;

  const MostSelectedList({super.key, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16,
        20,
        16,
        MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        Text(
          context.l10n.mostPopularSpecialities,
          style: AppTextStyles.semiBold(16, AppColors.c1A0304),
        ),
        const VerticalSpacer(24),
        for (final item in items)
          _MostSelectedItem(item: item, onTap: () => onTap(item)),
      ],
    );
  }
}

/// `recycler_item_most_popular_majors_search.xml`.
class _MostSelectedItem extends StatelessWidget {
  final SpecialityModel item;
  final VoidCallback onTap;

  const _MostSelectedItem({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.cF8F6FA,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AppNetworkImage(
                    url: item.image,
                    width: 26,
                    height: 26,
                    fit: BoxFit.contain,
                  ),
                ),
                const HorizontalSpacer(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.semiBold(14, AppColors.c090B0E),
                      ),
                      const VerticalSpacer(7),
                      Text(
                        context.l10n.availableDoctorsWithNumber(
                          item.appointmentsCount.toString(),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.medium(13, AppColors.c666666),
                      ),
                    ],
                  ),
                ),
                const HorizontalSpacer(10),
                const AppSvg(AppAssets.icLastSearch),
              ],
            ),
            const VerticalSpacer(16),
            const SizedBox(
              height: 0.5,
              child: ColoredBox(color: AppColors.cE6E6E6),
            ),
          ],
        ),
      ),
    );
  }
}
