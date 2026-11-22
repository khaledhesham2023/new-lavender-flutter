import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../data/models/responses/speciality.dart';
import 'section_header.dart';
import '../../../../shared/widgets/speciality_item.dart';

/// "All medical specialities": 4-column grid. [items] is the list built by
/// `buildHomeSpecialities` (index 0 = offers tile, index 7 = "More").
class SpecialitiesSection extends StatelessWidget {
  static const int columns = 4;
  static const int moreIndex = 7;

  final List<SpecialityModel> items;
  final VoidCallback onShowAll;
  final VoidCallback onOffers;
  final VoidCallback onMore;
  final ValueChanged<SpecialityModel> onSpeciality;

  const SpecialitiesSection({
    super.key,
    required this.items,
    required this.onShowAll,
    required this.onOffers,
    required this.onMore,
    required this.onSpeciality,
  });

  Widget _tile(BuildContext context, int i) {
    final l10n = context.l10n;
    final item = items[i];
    if (i == 0) {
      return SpecialityItem(
        speciality: item,
        asset: AppAssets.icGift,
        title: l10n.medicalOffers,
        onTap: onOffers,
      );
    }
    if (i == moreIndex) {
      return SpecialityItem(
        speciality: item,
        asset: AppAssets.icMore,
        title: l10n.more,
        onTap: onMore,
      );
    }
    return SpecialityItem(speciality: item, onTap: () => onSpeciality(item));
  }

  @override
  Widget build(BuildContext context) {
    final rows = (items.length / columns).ceil();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: context.l10n.allMedicalSpecialities,
          onShowAll: onShowAll,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              for (var r = 0; r < rows; r++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var c = 0; c < columns; c++)
                        Expanded(
                          child: r * columns + c < items.length
                              ? _tile(context, r * columns + c)
                              : const SizedBox.shrink(),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
