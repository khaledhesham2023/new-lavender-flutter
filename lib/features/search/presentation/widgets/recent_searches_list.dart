import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/spacers.dart';
import '../../../../core/widgets/app_svg.dart';
import '../../../../data/models/responses/search.dart';

/// `layout_recent_search.xml`: "latest searches" header with "Remove all" and
/// one row per recent search.
class RecentSearchesList extends StatelessWidget {
  final List<RecentSearchModel> items;
  final ValueChanged<RecentSearchModel> onTap;
  final VoidCallback onRemoveAll;

  const RecentSearchesList({
    super.key,
    required this.items,
    required this.onTap,
    required this.onRemoveAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  l10n.latestSearchResults,
                  style: AppTextStyles.medium(14, AppColors.c666666),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onRemoveAll,
                child: Text(
                  l10n.removeAll,
                  style: AppTextStyles.medium(12, AppColors.cED1C24),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16,
              20,
              16,
              MediaQuery.paddingOf(context).bottom,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) =>
                _RecentItem(item: items[i], onTap: () => onTap(items[i])),
          ),
        ),
      ],
    );
  }
}

/// `recycler_item_recent_search.xml`.
class _RecentItem extends StatelessWidget {
  final RecentSearchModel item;
  final VoidCallback onTap;

  const _RecentItem({required this.item, required this.onTap});

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
                Expanded(
                  child: Text(
                    item.search ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.semiBold(14, AppColors.c090B0E),
                  ),
                ),
                const HorizontalSpacer(3),
                const AppSvg(AppAssets.icLastSearch),
              ],
            ),
            const VerticalSpacer(12),
            const SizedBox(
              height: 0.5,
              child: ColoredBox(color: AppColors.cE6E6E6),
            ),
            const VerticalSpacer(12),
          ],
        ),
      ),
    );
  }
}

/// `layout_try_to_search.xml`: the 100dp glass icon centered in the body with
/// the hint below it. Shown when there are no recent searches.
class TrySearchView extends StatelessWidget {
  const TrySearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final top = (constraints.maxHeight - 100) / 2;
        return Stack(
          children: [
            PositionedDirectional(
              start: 0,
              end: 0,
              top: top,
              child: const Center(
                child: AppSvg(AppAssets.icSearchGlass, width: 100, height: 100),
              ),
            ),
            PositionedDirectional(
              start: 16,
              end: 16,
              top: top + 100 + 16,
              child: Text(
                context.l10n.trySearchForDoctorOrSpeciality,
                textAlign: TextAlign.center,
                style: AppTextStyles.medium(14, AppColors.c251836),
              ),
            ),
          ],
        );
      },
    );
  }
}
