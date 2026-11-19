import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../data/models/responses/speciality.dart';

/// One tile of the specialities grid (`recycler_item_speciality.xml`): a 52dp
/// rounded square with the icon and a one-line name. Pass [asset] to show a
/// local icon (gift / more) instead of the network image. Reused by T17 / T19.
class SpecialityItem extends StatelessWidget {
  final SpecialityModel speciality;
  final String? asset;
  final String? title;
  final VoidCallback onTap;

  const SpecialityItem({
    super.key,
    required this.speciality,
    required this.onTap,
    this.asset,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cF8F6FA,
              borderRadius: BorderRadius.circular(55),
              border: Border.all(color: AppColors.cF8F6FA, width: 0.5),
            ),
            child: asset != null
                ? AppSvg(asset!)
                : AppNetworkImage(
                    url: speciality.image,
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                  ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 23,
            child: Text(
              title ?? speciality.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.semiBold(13),
            ),
          ),
        ],
      ),
    );
  }
}
